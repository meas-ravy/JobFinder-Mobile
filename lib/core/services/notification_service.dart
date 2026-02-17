import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:job_finder/core/constants/api_enpoint.dart';
import 'package:job_finder/core/helper/secure_storage.dart';
import 'package:job_finder/core/networks/dio_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background tasks
  await Firebase.initializeApp();
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
        // Handle notification tap
      },
    );

    // 2.5 Setup Background Handling
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotifications.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
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

      _logger.i('FCM Token: $fcmToken');

      final dio = setupAuthenticatedDio(ApiEnpoint.baseUrl);

      // The user provided this route: POST /api/notifications/register-device
      await dio.post(
        'api/notifications/register-device',
        data: {
          'deviceToken': fcmToken,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        },
      );
      _logger.i('Device token registered successfully');
    } catch (e) {
      _logger.e('Failed to register device token: $e');
    }
  }
}
