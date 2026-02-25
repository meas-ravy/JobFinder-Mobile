import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:job_finder/core/constants/api_enpoint.dart';
import 'package:job_finder/core/helper/secure_storage.dart';
import 'package:job_finder/core/networks/dio_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder/core/routes/app_route.dart';
import 'package:logger/logger.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';

Future<void> showCallkitIncoming(Map<String, dynamic> data) async {
  final uuid = data['conversationId'] ?? const Uuid().v4();
  final callerName = data['title'] ?? data['senderName'] ?? 'Incoming Call';
  final callerAvatar = data['imageUrl'] ?? data['senderAvatar'] ?? '';
  final callType = data['callType'] ?? 'VIDEO';
  final isVideo = callType == 'VIDEO';

  CallKitParams callKitParams = CallKitParams(
    id: uuid,
    nameCaller: callerName,
    appName: 'Jober',
    avatar: callerAvatar,
    handle: "Incoming Call",
    type: isVideo ? 1 : 0,
    duration: 30000,
    textAccept: 'Accept',
    textDecline: 'Decline',
    extra: data,
    android: const AndroidParams(
      isCustomNotification: true,
      isShowLogo: false,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#0955fa',
      actionColor: '#4CAF50',
    ),
    ios: const IOSParams(
      iconName: 'CallKitLogo',
      handleType: '',
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
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background tasks
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (e) {
    // Already initialized or other error
  }

  final data = message.data;
  final String? type = data['type'] ?? data['signalType'];

  if (type == 'INCOMING_CALL' || type == 'START_CALL') {
    await showCallkitIncoming(data);
  }

  Logger().i("Handling a background message: ${message.messageId}");
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final _logger = Logger();

  Future<void> initialize() async {
    // 1. Request Permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _logger.i('User granted permission');
    } else {
      _logger.w('User declined or has not accepted permission');
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
        if (details.payload != null) {
          handleLink(details.payload!);
        }
      },
    );

    // Setup CallKit Events
    FlutterCallkitIncoming.onEvent.listen((event) {
      switch (event!.event) {
        case Event.actionCallAccept:
          final data = Map<String, dynamic>.from(event.body['extra'] ?? {});
          final channelName = data['conversationId'] ?? data['channelName'];
          final callType = data['callType'] ?? 'VIDEO';
          final remoteName =
              data['title'] ?? data['senderName'] ?? 'Incoming Call';

          if (channelName != null) {
            final route =
                '/call?channelName=$channelName&isVideoCall=${callType == 'VIDEO'}&remoteName=$remoteName';
            handleLink(route);
          }
          break;
        case Event.actionCallDecline:
          // Optional: Send decline ping to backend with signalType: "MISSED_CALL"
          // We can add logic to ping your /api/agora/call-signal here in the future
          break;
        default:
          break;
      }
    });

    // 2.5 Setup Background Handling
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle initial message (when app is opened from terminated state)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        final data = message.data;
        final String? type = data['type'] ?? data['signalType'];

        if (type == 'INCOMING_CALL' || type == 'START_CALL') {
          final channelName = data['conversationId'] ?? data['channelName'];
          final callType = data['callType'] ?? 'VIDEO';
          final remoteName =
              data['title'] ?? data['senderName'] ?? 'Incoming Call';
          data['link'] =
              '/incoming-call?channelName=$channelName&isVideoCall=${callType == 'VIDEO'}&remoteName=$remoteName';
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
      final String? type = data['type'] ?? data['signalType'];

      if (type == 'INCOMING_CALL' || type == 'START_CALL') {
        final channelName = data['conversationId'] ?? data['channelName'];
        final callType = data['callType'] ?? 'VIDEO';
        final remoteName =
            data['title'] ?? data['senderName'] ?? 'Incoming Call';
        data['link'] =
            '/incoming-call?channelName=$channelName&isVideoCall=${callType == 'VIDEO'}&remoteName=$remoteName';
      }
      final link = data['link'];
      if (link != null && link.toString().isNotEmpty) {
        handleLink(link.toString());
      }
    });

    // 3. Setup Android Channel
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }

    // 4. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final storage = TokenStorageImpl(const FlutterSecureStorage());
      final activeRole = await storage.readRole();

      final data = message.data;
      final targetRole = data['targetRole'] ?? 'Both';
      final String? type = data['type'] ?? data['signalType'];

      if (type == 'INCOMING_CALL' || type == 'START_CALL') {
        final channelName = data['conversationId'] ?? data['channelName'];
        final callType = data['callType'] ?? 'VIDEO';
        final remoteName =
            data['title'] ?? data['senderName'] ?? 'Incoming Call';

        // Construct deep link for the call
        data['link'] =
            '/incoming-call?channelName=$channelName&isVideoCall=${callType == 'VIDEO'}&remoteName=$remoteName';
      }

      // Filtering Logic
      if (targetRole != 'Both' &&
          activeRole != null &&
          targetRole != activeRole) {
        _logger.i(
          'Skipping foreground notification: Target role ($targetRole) does not match active role ($activeRole)',
        );
        return;
      }

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

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

      // If foreground call signal, aggressively push callkit overlay
      if (type == 'INCOMING_CALL' || type == 'START_CALL') {
        showCallkitIncoming(Map<String, dynamic>.from(data));
      }
    });

    // 5. Register Token to Backend
    await registerDeviceToken();

    // 6. Listen for Token Refresh
    _fcm.onTokenRefresh.listen((newToken) {
      registerDeviceToken(token: newToken);
    });
  }

  Future<void> handleLink(String link) async {
    _logger.i('Handling link: $link');

    // Wait for context to be available (useful for cold starts)
    int retryCount = 0;
    while (rootNavigatorKey.currentContext == null && retryCount < 50) {
      await Future.delayed(const Duration(milliseconds: 200));
      retryCount++;
    }

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      _logger.e('Navigator context is null after retries, cannot navigate');
      return;
    }

    // Use push to keep the back stack
    try {
      final String targetPath = link.startsWith('/') ? link : '/$link';
      _logger.i('Navigating to: $targetPath');
      context.push(targetPath);
    } catch (e) {
      _logger.e('Failed to navigate to link $link: $e');
    }
  }

  Future<void> registerDeviceToken({String? token}) async {
    try {
      // Only register if the user is authenticated
      final storage = TokenStorageImpl(const FlutterSecureStorage());
      final accessToken = await storage.read();
      if (accessToken == null || accessToken.isEmpty) {
        _logger.i('Skipping token registration: User not authenticated');
        return;
      }

      final fcmToken = token ?? await _fcm.getToken();
      if (fcmToken == null) return;

      final role = await storage.readRole();

      _logger.i('FCM Token: $fcmToken, Role: $role');

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
      _logger.i('Device token registered successfully');
    } catch (e) {
      _logger.e('Failed to register device token: $e');
    }
  }
}
