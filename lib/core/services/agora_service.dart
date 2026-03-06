import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:job_finder/core/constants/api_enpoint.dart';
import 'package:job_finder/core/helper/secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// The state of a call, stored in Firebase for signaling.
enum CallState { idle, ringing, ongoing, ended, missed, rejected }

/// Represents an incoming call invitation from Firebase.
class CallInvitation {
  final String callerId;
  final String callerName;
  final String callerAvatar;
  final String conversationId;
  final bool isVideoCall;

  CallInvitation({
    required this.callerId,
    required this.callerName,
    required this.callerAvatar,
    required this.conversationId,
    required this.isVideoCall,
  });

  factory CallInvitation.fromMap(Map<dynamic, dynamic> map) {
    return CallInvitation(
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? 'Unknown',
      callerAvatar: map['callerAvatar'] ?? '',
      conversationId: map['conversationId'] ?? '',
      isVideoCall: map['isVideoCall'] ?? false,
    );
  }
}

/// AgoraService manages video/voice calls via Agora RTC Engine.
/// Firebase Realtime Database is used for the signaling (ringing/accept/reject).
class AgoraService {
  AgoraService._();
  static final AgoraService instance = AgoraService._();

  final _logger = Logger();
  RtcEngine? _engine;
  StreamSubscription? _callSignalSubscription;

  // Bridges Agora's async callback result into a proper Future
  Completer<void>? _joinCompleter;

  // State streams for UI to listen to
  final _incomingCallController = StreamController<CallInvitation?>.broadcast();
  final _callStateController = StreamController<CallState>.broadcast();
  final _remoteUserJoinedController = StreamController<int>.broadcast();
  final _remoteUserLeftController = StreamController<int>.broadcast();

  Stream<CallInvitation?> get incomingCallStream =>
      _incomingCallController.stream;
  Stream<CallState> get callStateStream => _callStateController.stream;
  Stream<int> get remoteUserJoinedStream => _remoteUserJoinedController.stream;
  Stream<int> get remoteUserLeftStream => _remoteUserLeftController.stream;

  final _dio = Dio();
  final _db = FirebaseDatabase.instance;

  /// Initialize the Agora RTC Engine. Call once at app startup.
  Future<void> initialize(String appId) async {
    if (_engine != null) return;

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      RtcEngineContext(
        appId: appId,
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

  // ─────────────────────────────────────────────────────────────────────
  // SIGNALING via Firebase (the "Ringing" phase)
  // ─────────────────────────────────────────────────────────────────────

  DatabaseReference _callRef(String conversationId) =>
      _db.ref('calls/$conversationId');

  /// CALLER: Sends a call invitation over Firebase and starts listening for response.
  Future<void> sendCallInvitation({
    required String conversationId,
    required String callerId,
    required String callerName,
    required String callerAvatar,
    required bool isVideoCall,
  }) async {
    final ref = _callRef(conversationId);

    await ref.set({
      'state': 'ringing',
      'callerId': callerId,
      'callerName': callerName,
      'callerAvatar': callerAvatar,
      'conversationId': conversationId,
      'isVideoCall': isVideoCall,
      'timestamp': ServerValue.timestamp,
    });

    _logger.i('Call invitation sent for conversation: $conversationId');
    _callStateController.add(CallState.ringing);
  }

  /// RECEIVER: Listens to Firebase for incoming call invitations.
  void listenForIncomingCalls(String myUserId) {
    _callSignalSubscription?.cancel();

    // Listen to all conversations where this user might be called
    _db.ref('calls').onChildChanged.listen((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        final map = Map<dynamic, dynamic>.from(data);
        if (map['state'] == 'ringing' && map['callerId'] != myUserId) {
          final invitation = CallInvitation.fromMap(map);
          _incomingCallController.add(invitation);
          _callStateController.add(CallState.ringing);
        } else if (map['state'] == 'ended' || map['state'] == 'rejected') {
          _incomingCallController.add(null);
          _callStateController.add(CallState.ended);
        }
      }
    });
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

  // ─────────────────────────────────────────────────────────────────────
  // AGORA RTC (The actual call)
  // ─────────────────────────────────────────────────────────────────────

  /// Join an Agora channel.
  /// - If your Agora project is in **Testing Mode** (no App Certificate),
  ///   no token is required and we join directly.
  /// - If your backend has a token endpoint, we fetch it and use it.
  Future<void> joinCall({
    required String conversationId,
    required bool isVideoCall,
  }) async {
    if (_engine == null) {
      throw Exception('Agora engine not initialized. Call initialize() first.');
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

  /// End the call — leave Agora channel and update Firebase state.
  Future<void> endCall(String conversationId) async {
    await _engine?.leaveChannel();
    await _callRef(conversationId).update({'state': 'ended'});
    _callStateController.add(CallState.ended);
    _logger.i('Call ended for conversation: $conversationId');
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
    // ✅ setDefaultAudioRouteToSpeakerphone is the correct API in SDK 6.x
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
