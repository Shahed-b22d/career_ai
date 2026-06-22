import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ─── Background message handler (must be top-level) ────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase already shows the notification in background/terminated state.
  // We just save it to local storage so the notifications screen can show it.
  await _saveNotification(
    title: message.notification?.title ?? message.data['title'] ?? 'CareerAI',
    body:  message.notification?.body  ?? message.data['body']  ?? '',
    time:  DateTime.now().toIso8601String(),
  );
}

// ─── Helper: persist notification to SharedPreferences ──────────────────────
Future<void> _saveNotification({
  required String title,
  required String body,
  required String time,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> stored = prefs.getStringList('fcm_notifications') ?? [];
  // Store as "title|||body|||time"
  stored.insert(0, '$title|||$body|||$time');
  // Keep only last 50
  if (stored.length > 50) stored.removeLast();
  await prefs.setStringList('fcm_notifications', stored);
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // ─── Init ────────────────────────────────────────────────────────────────
  Future<void> init() async {
    // Local notifications setup
    const androidSettings =
        AndroidInitializationSettings('@drawable/ic_stat_notification');
    await _local.initialize(
      const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload == 'open_mail' && Platform.isAndroid) {
          const AndroidIntent intent = AndroidIntent(
            action: 'android.intent.action.MAIN',
            category: 'android.intent.category.APP_EMAIL',
            flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
          );
          await intent.launch();
        }
      },
    );

    // FCM foreground handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // Save to local list
      await _saveNotification(
        title: message.notification?.title ?? message.data['title'] ?? 'CareerAI',
        body:  message.notification?.body  ?? message.data['body']  ?? '',
        time:  DateTime.now().toIso8601String(),
      );
      // Show local notification while app is open
      await showNotification(
        id:    message.hashCode,
        title: message.notification?.title ?? message.data['title'] ?? 'CareerAI',
        body:  message.notification?.body  ?? message.data['body']  ?? '',
      );
    });

    // When user taps notification and app was in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await _saveNotification(
        title: message.notification?.title ?? message.data['title'] ?? 'CareerAI',
        body:  message.notification?.body  ?? message.data['body']  ?? '',
        time:  DateTime.now().toIso8601String(),
      );
    });

    // Send current FCM token to backend (if authenticated) and listen for token refresh
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await _sendTokenToServer(token);
      }

      _fcm.onTokenRefresh.listen((newToken) async {
        await _sendTokenToServer(newToken);
      });
    } catch (e) {
      // ignore errors here — token send is best-effort
    }
  }

  // ─── Request permission ──────────────────────────────────────────────────
  Future<void> requestPermission() async {
    // FCM permission (iOS + Android 13+)
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Local notifications permission (Android 13+)
    final androidImpl = _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
  }

  // ─── Get FCM token (send this to your backend) ───────────────────────────
  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  // ─── Helper: send token to backend API `/api/auth/fcm-token` ─────────────
  // Expects the app to store the user's API token in SharedPreferences under 'api_token'.
  // Update `_apiBase` to point to your backend (use emulator host for Android emulator: 10.0.2.2).
  static const String _apiBase = 'http://127.0.0.1:8000';

  Future<void> _sendTokenToServer(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiToken = prefs.getString('auth_token');
      if (apiToken == null || apiToken.isEmpty) return; // not logged in

      final url = Uri.parse('$_apiBase/api/auth/fcm-token');

      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $apiToken',
        },
        body: jsonEncode({'fcm_token': token}),
      );

      // optional: handle non-200 responses if needed
    } catch (e) {
      // best-effort send
    }
  }

  // ─── Show local notification ─────────────────────────────────────────────
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'career_ai_channel',
      'Career AI Notifications',
      channelDescription: 'Main channel for app notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@drawable/ic_stat_notification',
    );
    await _local.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  // ─── Get saved notifications ─────────────────────────────────────────────
  static Future<List<Map<String, String>>> getSavedNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('fcm_notifications') ?? [];
    return stored.map((s) {
      final parts = s.split('|||');
      return {
        'title': parts.isNotEmpty ? parts[0] : '',
        'body':  parts.length > 1 ? parts[1] : '',
        'time':  parts.length > 2 ? parts[2] : '',
      };
    }).toList();
  }

  // ─── Clear all notifications ─────────────────────────────────────────────
  static Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fcm_notifications');
  }
}
