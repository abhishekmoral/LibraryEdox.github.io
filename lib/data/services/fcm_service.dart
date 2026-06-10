import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:edox_library/bindings/dependency_injection.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';

import 'package:edox_library/utils/logging/logger.dart';

/// A service that manages Firebase Cloud Messaging (FCM)
/// for push notifications in the EdoxLibrary application.
class FCMService {
  FCMService._();
  static final FCMService _instance = FCMService._();
  factory FCMService() => _instance;

  static FCMService get instance => locator<FCMService>();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // ──────────────────────────── Initialisation ───────────────────

  /// Requests permission, retrieves the FCM token, and sets up listeners.
  Future<void> init() async {
    try {
      XLoggerHelper.info('Initialising FCM service');

      // Request notification permissions (iOS & Android 13+).
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      XLoggerHelper.info(
        'FCM permission status: ${settings.authorizationStatus}',
      );

      // Retrieve the device token.
      final token = await getToken();
      XLoggerHelper.info('FCM token: $token');

      // Setup foreground & tap handlers.
      setupForegroundNotification();
      handleNotificationTap();
    } catch (e, st) {
      XLoggerHelper.error('FCM initialisation failed', error: e, stackTrace: st);
    }
  }

  // ──────────────────────────── Token ────────────────────────────

  /// Returns the current FCM device token, or `null` if unavailable.
  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      return token;
    } catch (e, st) {
      XLoggerHelper.error('Failed to get FCM token', error: e, stackTrace: st);
      return null;
    }
  }

  // ──────────────────────────── Foreground ───────────────────────

  /// Listens for messages while the app is in the foreground.
  void setupForegroundNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      XLoggerHelper.info(
        'Foreground notification received: ${message.notification?.title}',
      );
      // The app can show an in-app banner / snackbar here.
      if (message.notification != null) {
        XHelperFunctions.showSnackBar(
          message.notification?.body ?? '',
        );
      }
    });
  }

  // ──────────────────────────── Tap Handling ─────────────────────

  /// Handles notification taps when the app was in the background or terminated.
  void handleNotificationTap() {
    // App was in background and user tapped the notification.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      XLoggerHelper.info(
        'Notification tapped (background): ${message.data}',
      );
      _routeFromMessage(message);
    });

    // App was terminated and user tapped the notification.
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        XLoggerHelper.info(
          'Notification tapped (terminated): ${message.data}',
        );
        _routeFromMessage(message);
      }
    });
  }

  /// Internal helper to navigate based on the notification payload.
  void _routeFromMessage(RemoteMessage message) {
    final data = message.data;
    if (data.containsKey('route')) {
      XHelperFunctions.navigatorKey.currentState?.pushNamed(data['route'] as String);
    }
  }
}
