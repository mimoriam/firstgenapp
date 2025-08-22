import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firstgenapp/main.dart';
import 'package:firstgenapp/models/chat_models.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/chats/conversation/conversation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}");
  // You can perform data-only message handling here, e.g., updating a local database.
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _requestPermissions();
    await _initLocalNotifications();
    _configureFirebaseMessagingListeners();
  }

  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      log('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    log('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  void onDidReceiveNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      log('Notification payload: ${response.payload}');
      final Map<String, dynamic> data = jsonDecode(response.payload!);
      _handleNotificationNavigation(data);
    }
  }

  void _configureFirebaseMessagingListeners() {
    // For handling messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message);
      }
    });

    // For handling messages when the app is in the background or terminated
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // For handling when a user taps a notification and opens the app from the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('A new onMessageOpenedApp event was published!');
      _handleNotificationNavigation(message.data);
    });

    // For handling when a user taps a notification and opens the app from a terminated state
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        log('App opened from a terminated state by a notification');
        _handleNotificationNavigation(message.data);
      }
    });
  }

  void _showLocalNotification(RemoteMessage message) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'firstgen_chat_channel',
          'Chat Notifications',
          channelDescription: 'This channel is used for chat notifications.',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final conversationId = data['conversationId'];
    final otherUserJson = data['otherUser'];
    if (conversationId != null && otherUserJson != null) {
      final otherUser = ChatUser.fromJson(jsonDecode(otherUserJson));
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => ConversationScreen(otherUser: otherUser),
        ),
      );
    }
  }
}
