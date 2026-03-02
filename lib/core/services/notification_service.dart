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

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background tasks
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
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

    // Setup Background Handling
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle initial message (when app is opened from terminated state)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        final data = message.data;
        final link = data['link'];
        if (link != null && link.toString().isNotEmpty) {
          handleLink(link.toString());
        }
      }
    });

    // Handle background messages tapped while app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final data = message.data;
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

      // Filtering Logic
      if (targetRole != 'Both' &&
          activeRole != null &&
          targetRole != activeRole) {
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

    // 5. Register Token to Backend
    await registerDeviceToken();

    // 6. Listen for Token Refresh
    _fcm.onTokenRefresh.listen((newToken) {
      registerDeviceToken(token: newToken);
    });
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
    final String targetPath = link.startsWith('/') ? link : '/$link';
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
