import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:job_finder/core/constants/api_enpoint.dart';
import 'package:job_finder/core/helper/secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// The state of a call, stored in Firebase for signaling.
enum CallState { idle, ringing, ongoing, ended, missed, rejected }

/// Represents an incoming call invitation from Firebase.
class CallInvitation {
  final String callerId;
  final String callerName;
  final String? callerAvatar;
  final String calleeId;
  final String conversationId;
  final bool isVideoCall;

  CallInvitation({
    required this.callerId,
    required this.callerName,
    this.callerAvatar,
    required this.calleeId,
    required this.conversationId,
    required this.isVideoCall,
  });

  factory CallInvitation.fromMap(Map<dynamic, dynamic> map) {
    return CallInvitation(
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? 'Unknown',
      callerAvatar: map['callerAvatar'] as String?,
      calleeId: map['calleeId'] ?? '',
      conversationId: map['conversationId'] ?? '',
      isVideoCall: map['isVideoCall'] ?? false,
    );
  }
}

// AgoraService manages video/voice calls via Agora RTC Engine.
// Firebase Realtime Database is used for the signaling (ringing/accept/reject).
class AgoraService {
  AgoraService._();
  static final AgoraService instance = AgoraService._();

  final _logger = Logger();
  RtcEngine? _engine;
  String? _appId; // Store the App ID for re-initialization
  StreamSubscription? _callSignalSubscription;

  // Bridges Agora's async callback result into a proper Future
  Completer<void>? _joinCompleter;

  // State streams for UI to listen to
  final _incomingCallController = StreamController<CallInvitation?>.broadcast();
  final _callStateController = StreamController<CallState>.broadcast();
  final _remoteUserJoinedController = StreamController<int>.broadcast();
  final _remoteUserLeftController = StreamController<int>.broadcast();

  String? _fcmToken;
  bool _isMessagingInitialized = false;
  StreamSubscription? _activeCallSub;

  Stream<CallInvitation?> get incomingCallStream =>
      _incomingCallController.stream;
  Stream<CallState> get callStateStream => _callStateController.stream;
  Stream<int> get remoteUserJoinedStream => _remoteUserJoinedController.stream;
  Stream<int> get remoteUserLeftStream => _remoteUserLeftController.stream;

  /// Exposes the underlying RtcEngine so the UI can create stable VideoViewControllers.
  RtcEngine? get engine => _engine;

  final _dio = Dio();
  final _db = FirebaseDatabase.instance;

  /// Initialize the Agora RTC Engine.
  Future<void> initialize(String appId) async {
    _appId = appId; // Save the App ID
    if (_engine != null) return;

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      RtcEngineContext(
        appId: _appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    _setupEventHandlers();
    _logger.i('Agora RTC Engine initialized');
  }

  void _setupEventHandlers() {
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          _logger.i('✅ Joined Agora channel: ${connection.channelId}');
          // Complete the join future so joinCall() can return
          if (_joinCompleter != null && !_joinCompleter!.isCompleted) {
            _joinCompleter!.complete();
          }
          _callStateController.add(CallState.ongoing);
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          _logger.i('Remote user joined: $remoteUid');
          _remoteUserJoinedController.add(remoteUid);
        },
        onUserOffline: (connection, remoteUid, reason) {
          _logger.i('Remote user left: $remoteUid, reason: $reason');
          _remoteUserLeftController.add(remoteUid);
          _callStateController.add(CallState.ended);
        },
        onError: (err, msg) {
          _logger.e('❌ Agora error: $err - $msg');
          // Fail the join future so joinCall() throws the error
          if (_joinCompleter != null && !_joinCompleter!.isCompleted) {
            _joinCompleter!.completeError(Exception('Agora error $err: $msg'));
          }
        },
      ),
    );
  }

  /// Setup Firebase Messaging for push notifications.
  Future<void> setupFirebaseMessaging() async {
    if (_isMessagingInitialized) return;

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 1. Request permissions (especially for iOS)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _logger.i('FCM: User granted permission');
    } else {
      _logger.w('FCM: User declined or has not accepted permission');
    }

    // 2. Get the token
    _fcmToken = await messaging.getToken();
    _logger.i('FCM Token: $_fcmToken');

    _isMessagingInitialized = true;
  }

  /// Registers the current device token with the backend.
  Future<void> registerDeviceToken(String platform, String role) async {
    if (_fcmToken == null) {
      await setupFirebaseMessaging();
    }
    if (_fcmToken == null) return;

    try {
      final storage = TokenStorageImpl(const FlutterSecureStorage());
      final accessToken = await storage.read();

      if (accessToken == null) return;

      await _dio.post(
        '${ApiEnpoint.baseUrl}api/notifications/register-device',
        data: {'deviceToken': _fcmToken, 'platform': platform, 'role': role},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      _logger.i('FCM: Device token registered with backend');
    } catch (e) {
      _logger.e('FCM: Failed to register device token: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // SIGNALING via Firebase (the "Ringing" phase)
  // ─────────────────────────────────────────────────────────────────────

  DatabaseReference _callRef(String conversationId) =>
      _db.ref('calls/$conversationId');

  /// CALLER: Sends a call invitation via backend API (triggers signaling + push notification).
  Future<void> sendCallInvitation({
    required String conversationId,
    required String callerId,
    String? callerName,
    String? callerAvatar,
    required String calleeId,
    required bool isVideoCall,
    String? callerRole, // 'Recruiter' or 'Job_finder'
  }) async {
    try {
      final storage = TokenStorageImpl(const FlutterSecureStorage());
      final accessToken = await storage.read();
      final activeRole = callerRole ?? await storage.readRole();

      await _dio.post(
        '${ApiEnpoint.baseUrl}${ApiEnpoint.callInvite}',
        data: {
          'conversationId': conversationId,
          'callerId': callerId,
          'callerName': callerName,
          'callerAvatar': callerAvatar,
          'calleeId': calleeId,
          'isVideoCall': isVideoCall,
          'callerRole': activeRole,
        },
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      _logger.i(
        'Call invitation sent via backend for conversation: $conversationId',
      );
      _callStateController.add(CallState.ringing);
    } catch (e) {
      _logger.e('Failed to send call invitation: $e');
      rethrow;
    }
  }

  /// RECEIVER: Listens to Firebase for incoming call invitations.
  void listenForIncomingCalls(String myUserId) {
    _callSignalSubscription?.cancel();

    // Only get calls where I am the callee
    // Filter by timestamp to only get CURRENT calls (created in the last 2 minutes)
    final startTime = DateTime.now().millisecondsSinceEpoch - (120 * 1000);

    final query = _db.ref('calls').orderByChild('timestamp').startAt(startTime);

    // Watch for NEW calls (onChildAdded) and UPDATES to existing (onChildChanged)
    _callSignalSubscription = query.onChildAdded.listen((event) {
      _handleFirebaseCallEvent(event.snapshot.value, myUserId);
    });

    query.onChildChanged.listen((event) {
      _handleFirebaseCallEvent(event.snapshot.value, myUserId);
    });
  }

  void _handleFirebaseCallEvent(Object? data, String myUserId) {
    if (data is Map) {
      final map = Map<dynamic, dynamic>.from(data);
      final state = map['state'];
      final calleeId = map['calleeId'];

      // Must be 'ringing' and I must be the target
      if (state == 'ringing' && calleeId == myUserId) {
        final invitation = CallInvitation.fromMap(map);
        _incomingCallController.add(invitation);
        _callStateController.add(CallState.ringing);
      } else if (state == 'ended' || state == 'rejected' || state == 'missed') {
        _incomingCallController.add(null);
        _callStateController.add(CallState.ended);
      }
    }
  }

  /// Accept an incoming call invitation.
  Future<void> acceptCall(String conversationId) async {
    await _callRef(conversationId).update({'state': 'ongoing'});
    _incomingCallController.add(null);
  }

  /// Reject an incoming call invitation.
  Future<void> rejectCall(String conversationId) async {
    await _callRef(conversationId).update({'state': 'rejected'});
    _incomingCallController.add(null);
    _callStateController.add(CallState.rejected);
  }

  /// Watch the status of a specific call (used by the caller).
  void watchCallStatus(String conversationId) {
    _activeCallSub?.cancel();
    _activeCallSub = _callRef(conversationId).onValue.listen((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        final stateStr = data['state'];
        CallState? state;
        switch (stateStr) {
          case 'ringing':
            state = CallState.ringing;
            break;
          case 'ongoing':
            state = CallState.ongoing;
            break;
          case 'ended':
            state = CallState.ended;
            break;
          case 'rejected':
            state = CallState.rejected;
            break;
          case 'missed':
            state = CallState.missed;
            break;
        }
        if (state != null) {
          _callStateController.add(state);
        }
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────
  // AGORA RTC (The actual call)
  // ─────────────────────────────────────────────────────────────────────

  /// Join an Agora channel.
  /// - If Agora project is in **Testing Mode** (no App Certificate),
  ///   no token is required and we join directly.
  /// - If backend has a token endpoint, we fetch it and use it.
  Future<void> joinCall({
    required String conversationId,
    required bool isVideoCall,
  }) async {
    // If the engine was released previously, re-initialize it now
    if (_engine == null && _appId != null) {
      await initialize(_appId!);
    }

    if (_engine == null) {
      throw Exception(
        'Agora engine not initialized. Ensure initialize() was called at least once.',
      );
    }
    try {
      String? agoraToken;
      int uid = 0;

      // Try to fetch token from backend (optional — only if backend is ready)
      try {
        final storage = TokenStorageImpl(const FlutterSecureStorage());
        final accessToken = await storage.read();
        if (accessToken != null && accessToken.isNotEmpty) {
          final response = await _dio
              .get(
                '${ApiEnpoint.baseUrl}${ApiEnpoint.agoraToken(conversationId)}',
                options: Options(
                  headers: {'Authorization': 'Bearer $accessToken'},
                  receiveTimeout: const Duration(seconds: 5),
                ),
              )
              .timeout(const Duration(seconds: 5));
          agoraToken = response.data['token'] as String?;
          uid = (response.data['uid'] as num?)?.toInt() ?? 0;
          _logger.i('Agora token fetched from backend.');
        }
      } catch (e) {
        // Backend not ready yet — fall through to Testing Mode (null token)
        _logger.w('Agora backend token failed, joining in Testing Mode: $e');
        agoraToken = null; // null token works when App Certificate is disabled
        uid = 0;
      }

      // Enable video/audio
      if (isVideoCall) {
        await _engine!.enableVideo();
        await _engine!.startPreview();
      } else {
        await _engine!.disableVideo();
      }
      await _engine!.enableAudio();

      // Join the Agora channel
      // NOTE: joinChannel() is fire-and-forget. We use a Completer to wait
      // for the actual result via onJoinChannelSuccess / onError callbacks.
      _joinCompleter = Completer<void>();

      await _engine!.joinChannel(
        token: agoraToken ?? '', // empty string = Testing Mode (no certificate)
        channelId: conversationId,
        uid: uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishMicrophoneTrack: true,
          publishCameraTrack: true,
        ),
      );

      // Wait for onJoinChannelSuccess or onError (max 12 seconds)
      await _joinCompleter!.future.timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw Exception(
          'Connection timed out. Check your Agora App ID and network.',
        ),
      );

      _logger.i(
        '✅ Successfully joined Agora channel: $conversationId (uid=$uid)',
      );
    } catch (e) {
      _logger.e('Failed to join Agora call: $e');
      rethrow;
    }
  }

  // End the call — leave Agora channel and update Firebase state.
  Future<void> endCall(String conversationId) async {
    // Step 1: Leave Agora channel and Release resources
    // This stops the camera and microphone completely.
    try {
      if (_engine != null) {
        await _engine!.leaveChannel();
        await _engine!.release();
        _engine = null;
        _logger.i('Agora engine released and cleaned up');
      }
    } catch (e) {
      _logger.e('Error during Agora cleanup: $e');
    }

    // Step 2: Firebase update — fire and forget (do NOT await)
    // Awaiting this can hang indefinitely if Firebase rules deny
    // write access to the calls/ path or network is slow.
    _callRef(conversationId).update({'state': 'ended'}).catchError((e) {
      _logger.w('Firebase endCall update failed (ignored): $e');
    });

    // Step 3: Signal UI immediately — don't wait for Firebase
    _callStateController.add(CallState.ended);
    _logger.i('Call ended signal sent for: $conversationId');
  }

  /// Toggle microphone mute.
  Future<void> toggleMute(bool mute) async {
    await _engine?.muteLocalAudioStream(mute);
  }

  /// Toggle camera on/off.
  Future<void> toggleCamera(bool disable) async {
    await _engine?.muteLocalVideoStream(disable);
  }

  /// Switch between front and back camera.
  Future<void> switchCamera() async {
    await _engine?.switchCamera();
  }

  /// Enable Speaker/Earpiece
  /// Uses the modern API recommended by Agora SDK 6.x
  Future<void> setSpeakerOn(bool speakerOn) async {
    await _engine?.setDefaultAudioRouteToSpeakerphone(speakerOn);
  }

  /// Get the local video view widget.
  Widget getLocalView() {
    if (_engine == null) return const SizedBox.shrink();
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  /// Get the remote video view widget for a specific uid.
  Widget getRemoteView(int remoteUid, String channelId) {
    if (_engine == null) return const SizedBox.shrink();
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: remoteUid),
        connection: RtcConnection(channelId: channelId),
      ),
    );
  }

  /// Clean up resources.
  Future<void> dispose() async {
    _callSignalSubscription?.cancel();
    await _engine?.leaveChannel();
    await _engine?.release();
    _engine = null;
    _incomingCallController.close();
    _callStateController.close();
    _remoteUserJoinedController.close();
    _remoteUserLeftController.close();
  }
}
