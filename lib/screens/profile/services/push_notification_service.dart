
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../main.dart';
import '../../../services/in_app_notification_service.dart';
import '../../entry_screen.dart';

class PushNotificationService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'reminders';
  static const String channelName = 'Reminders';

  static String? _jwtToken;
  static String? _backendUrl;

  static Future<void> initialize({
    required String jwtToken,
    required String backendUrl,
  }) async {
    _jwtToken = jwtToken;
    _backendUrl = backendUrl;

    // Respect the user's push notification preference
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('push_notifications_enabled') ?? true;
    if (!enabled) {
      debugPrint('Push notifications disabled by user preference');
      return;
    }

    // Create the Android notification channel.
    const androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: 'Preply reminder notifications',
      importance: Importance.max,
      playSound: true,
    );

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap();
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Request notification permission.
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus ==
        AuthorizationStatus.denied) {
      debugPrint('Notification permission denied');
      return;
    }

    // Display notifications while the app is in foreground.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();

    if (token != null) {
      await _registerToken(token);
    }

    // Register a new token whenever Firebase refreshes it.
    _messaging.onTokenRefresh.listen((newToken) async {
      await _registerToken(newToken);
    });

    // Handle background notification clicks
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap();
    });

    // Check if app was opened from terminated state via push notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap();
    }

    // Check if app was launched via local notification tap
    final launchDetails =
        await _localNotifications.getNotificationAppLaunchDetails();
    if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
      _handleNotificationTap();
    }

    // Show a local notification for foreground messages.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;

      if (notification == null) return;

      // Track in the in-app notification system for the badge & bottom sheet
      await InAppNotificationService.addNotification(
        title: notification.title ?? 'Preply Reminder',
        body: notification.body ?? '',
        type: message.data['type'] ?? 'reminder',
        reminderId: message.data['reminderId'],
      );

      await _localNotifications.show(
        message.hashCode,
        notification.title ?? 'Preply Reminder',
        notification.body ?? '',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: 'Preply reminder notifications',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    });

    debugPrint('Push notifications initialized');
  }

  static void _handleNotificationTap() {
    debugPrint('Notification tapped -> Opening Reminders tab in EntryScreen');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (EntryScreen.hasActiveState) {
        // Pop any overlay/details screens so EntryScreen is showing
        navigatorKey.currentState?.popUntil((route) => route.isFirst);
        EntryScreen.openTab(3);
      } else {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => EntryScreen(
                token: token,
                initialIndex: 3,
              ),
            ),
            (route) => false,
          );
        }
      }
    });
  }

  static Future<void> _registerToken(String token) async {
    final jwt = _jwtToken;
    final backend = _backendUrl;

    if (jwt == null || backend == null) return;

    final uri = Uri.parse('$backend/api/notification/register-token');
    var response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode({'token': token}),
    );

    // Fallback if backend uses plural /notifications
    if (response.statusCode == 404) {
      response = await http.post(
        Uri.parse('$backend/api/notifications/register-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode({'token': token}),
      );
    }

    if (response.statusCode != 200) {
      throw Exception(
        'FCM token registration failed: ${response.body}',
      );
    }

    debugPrint('FCM token registered successfully');
  }
}
