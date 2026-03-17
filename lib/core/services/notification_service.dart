import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:job_finder/core/constants/api_enpoint.dart';
import 'package:job_finder/core/helper/secure_storage.dart';
import 'package:job_finder/core/networks/dio_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder/core/routes/app_route.dart';
import 'package:job_finder/core/services/agora_service.dart';
import 'package:job_finder/shared/screen/incoming_call_screen.dart';
import 'package:job_finder/shared/screen/agora_call_screen.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:job_finder/firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📩 [FCM Background] Message received: ${message.data}');

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    if (!e.toString().contains('duplicate-app')) {
      debugPrint('⚠️ [FCM Background] Firebase init error: $e');
    }
  }

  final data = message.data;
  final type = data['type']?.toString().toUpperCase();

  debugPrint('🔍 [FCM Background] Message type: $type');

  if (type == 'INCOMING_CALL') {
    debugPrint('📞 [FCM Background] Triggering CallKit...');
    final uuid = DateTime.now().millisecondsSinceEpoch.toString();
    final callKitParams = CallKitParams(
      id: uuid,
      nameCaller: data['callerName'] ?? 'Unknown',
      appName: 'Job Finder',
      avatar: data['callerAvatar'],
      handle: data['isVideoCall'] == 'true' ? 'Video Call' : 'Voice Call',
      type: data['isVideoCall'] == 'true' ? 1 : 0,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      extra: <String, dynamic>{...data},
      headers: <String, dynamic>{'Color': '#1A1A2E'},
      android: const AndroidParams(
        isCustomNotification: false, // Standard UI is more reliable
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#1A1A2E',
        actionColor: '#4CAF50',
        incomingCallNotificationChannelName: 'Incoming Calls',
        isShowFullLockedScreen: true,
      ),
      ios: const IOSParams(
        iconName: 'AppIcon',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
    debugPrint('✅ [FCM Background] CallKit shown');
  } else {
    // Show static notification for other types (e.g., job approval)
    final notification = message.notification;
    final title = notification?.title ?? data['title'];
    final body = notification?.body ?? data['body'];

    if (title != null || body != null) {
      debugPrint('🔔 [FCM Background] Showing static notification: $title');
      // Note: We can't use instance methods here as it's a top-level isolate
      final local = FlutterLocalNotificationsPlugin();
      await local.show(
        id: notification?.hashCode ?? DateTime.now().millisecond,
        title: title,
        body: body,
        payload: data['link']?.toString(), // Added payload for deep linking
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  }
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 1. Request Permission
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Specifically request for Android 13+
    if (Platform.isAndroid) {
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      // For CallKit to work over lock screen/other apps
      if (await Permission.systemAlertWindow.isDenied) {
        await Permission.systemAlertWindow.request();
      }
    }

    // 2. Setup Local Notifications (for foreground messages)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        final actionId = details.actionId;

        if (payload != null) {
          if (payload.startsWith('INCOMING_CALL|')) {
            final parts = payload.split('|');
            if (parts.length >= 6) {
              final data = {
                'conversationId': parts[1],
                'callerName': parts[2],
                'callerAvatar': parts[3],
                'callerId': parts[4],
                'isVideoCall': parts[5],
              };

              if (actionId == 'decline_call') {
                AgoraService.instance.rejectCall(data['conversationId']!);
              } else {
                // Tapping 'Accept' button joins immediately.
                // Tapping the notification body (actionId == null) shows the incoming screen.
                _handleIncomingCallMessage(
                  data,
                  autoAccept: actionId == 'accept_call',
                );
              }
            }
          } else {
            handleLink(payload);
          }
        }
      },
    );

    // Setup Background Handling
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle initial message (when app is opened from terminated state)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        debugPrint('🔔 FCM Initial Message Data: ${message.data}');
        final data = message.data;

        // Check for incoming call
        if (data['type']?.toString().toUpperCase() == 'INCOMING_CALL') {
          _handleIncomingCallMessage(data);
          return;
        }

        final link = data['link'];
        if (link != null && link.toString().isNotEmpty) {
          handleLink(link.toString());
        }
      }
    });

    // Handle background messages tapped while app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final data = message.data;
      debugPrint('🔔 FCM Message Opened App: ${data}');

      // Check for incoming call
      if (data['type']?.toString().toUpperCase() == 'INCOMING_CALL') {
        _handleIncomingCallMessage(data);
        return;
      }

      final link = data['link'];
      if (link != null && link.toString().isNotEmpty) {
        handleLink(link.toString());
      }
    });

    // 3. Setup Android Channels
    if (Platform.isAndroid) {
      final channels = [
        const AndroidNotificationChannel(
          'high_importance_channel',
          'General Notifications',
          description: 'Used for general app notifications.',
          importance: Importance.max,
        ),
        const AndroidNotificationChannel(
          'incoming_calls_channel',
          'Incoming Calls',
          description: 'Used for incoming video and voice calls.',
          importance: Importance.max,
          playSound: true,
        ),
      ];

      for (var channel in channels) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(channel);
      }
    }

    // 4. Handle Foreground Messages (app is open)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('🔔 FCM Foreground Message Data: ${message.data}');
      final data = message.data;

      // ── Incoming Call Message ──
      // Use case-insensitive check to be safe
      final type = data['type']?.toString().toUpperCase();
      if (type == 'INCOMING_CALL') {
        debugPrint('📞 Detected incoming call in foreground');
        _handleIncomingCallMessage(data);
        return; // Don't show a regular notification
      }

      final storage = TokenStorageImpl(const FlutterSecureStorage());
      final activeRole = await storage.readRole();
      final targetRole = data['targetRole'] ?? 'Both';

      // Filtering Logic (Case-insensitive to prevent silent drops)
      if (targetRole.toString().toLowerCase() != 'both' &&
          activeRole != null &&
          targetRole.toString().toLowerCase() != activeRole.toLowerCase()) {
        debugPrint(
          "Notification dropped: targetRole=$targetRole, activeRole=$activeRole",
        );
        return;
      }

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // We only show notifications if there is a push notification obj.
      if (notification != null && android != null) {
        _localNotifications.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          payload: data['link'], // Pass link as payload
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    // Register Token to Backend
    await registerDeviceToken();

    // 7. Listen for CallKit Events (Native UI Answer/Hangup)
    FlutterCallkitIncoming.onEvent.listen((event) {
      if (event == null) return;
      final data = event.body['extra'] as Map<dynamic, dynamic>?;
      if (data == null) return;

      final map = Map<String, dynamic>.from(data);

      switch (event.event) {
        case Event.actionCallAccept:
          debugPrint('📞 [CallKit] User accepted call from native UI');
          _handleIncomingCallMessage(map, autoAccept: true);
          break;
        case Event.actionCallDecline:
          debugPrint('📱 [CallKit] User declined call from native UI');
          AgoraService.instance.rejectCall(
            map['conversationId']?.toString() ?? '',
          );
          break;
        default:
          break;
      }
    });

    // 8. Listen for Token Refresh
    _fcm.onTokenRefresh.listen((newToken) {
      registerDeviceToken(token: newToken);
    });
  }

  /// Handles an incoming call FCM payload by showing the IncomingCallScreen.
  void _handleIncomingCallMessage(
    Map<String, dynamic> data, {
    bool autoAccept = false,
  }) async {
    debugPrint('📞 Incoming Call Message (autoAccept: $autoAccept): $data');

    // Wait for context
    int retryCount = 0;
    while (rootNavigatorKey.currentContext == null && retryCount < 30) {
      await Future.delayed(const Duration(milliseconds: 200));
      retryCount++;
    }
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      debugPrint('❌ Context null - cannot show call screen');
      return;
    }

    final invitation = CallInvitation(
      conversationId: data['conversationId']?.toString() ?? '',
      callerId: (data['callerId'] ?? data['user_id'] ?? '').toString(),
      callerName: data['callerName'] ?? data['user_name'] ?? 'Unknown',
      callerAvatar: data['callerAvatar'] ?? data['user_image'],
      calleeId: data['calleeId']?.toString() ?? '',
      isVideoCall: data['isVideoCall'] == 'true' || data['isVideoCall'] == true,
    );

    // Only conversationId is strictly required by Agora
    if (invitation.conversationId.isEmpty) {
      debugPrint('❌ Error: conversationId is missing in FCM data');
      return;
    }

    debugPrint('🚀 Showing IncomingCallScreen for ${invitation.callerName}');
    if (autoAccept) {
      debugPrint('🚀 [NotificationService] Auto-accepting and joining call...');
      AgoraService.instance.acceptCall(invitation.conversationId);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AgoraCallScreen(
            conversationId: invitation.conversationId,
            callerName: invitation.callerName,
            callerAvatar: invitation.callerAvatar,
            calleeId: invitation.callerId,
            calleeName: invitation.callerName,
            isVideoCall: invitation.isVideoCall,
            isIncoming: true,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => IncomingCallScreen(invitation: invitation),
        ),
      );
    }
  }

  Future<void> handleLink(String link) async {
    // Wait for context to be available
    int retryCount = 0;
    while (rootNavigatorKey.currentContext == null && retryCount < 50) {
      await Future.delayed(const Duration(milliseconds: 200));
      retryCount++;
    }

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      return;
    }

    // Use push to keep the back stack
    String targetPath = link.startsWith('/') ? link : '/$link';

    // If target is recruiter home, force it to the "Active" tab (subTab=0)
    if (targetPath == '/recruiter') {
      targetPath = '/recruiter?subTab=0';
    }

    context.push(targetPath);
  }

  Future<void> registerDeviceToken({String? token}) async {
    // Only register if the user is authenticated
    final storage = TokenStorageImpl(const FlutterSecureStorage());
    final accessToken = await storage.read();
    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    final fcmToken = token ?? await _fcm.getToken();
    if (fcmToken == null) return;
    final role = await storage.readRole();
    final dio = setupAuthenticatedDio(ApiEnpoint.baseUrl);

    // The user provided this route: POST /api/notifications/register-device
    await dio.post(
      'api/notifications/register-device',
      data: {
        'deviceToken': fcmToken,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'role': role,
      },
    );
  }
}
