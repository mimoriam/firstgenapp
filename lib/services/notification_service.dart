import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firstgenapp/main.dart';
import 'package:firstgenapp/models/chat_models.dart';
import 'package:firstgenapp/models/community_models.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/chats/conversation/conversation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

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
    var status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
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
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('A new onMessageOpenedApp event was published!');
      _handleNotificationNavigation(message.data);
    });

    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        log('App opened from a terminated state by a notification');
        _handleNotificationNavigation(message.data);
      }
    });
  }

  void setupForegroundNotificationListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message); // Use local notifications
      }
    });
  }

  void _showLocalNotification(RemoteMessage message) {
    // Use the channel ID from your AndroidManifest.xml
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'firstgen_chat_channel',
          'Chat Notifications',
          channelDescription: 'This channel is used for chat notifications.',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true, // Show the timestamp
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      // You can also configure iOS details here
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
    } else {
      log("Handled a general notification. No navigation action taken.");
    }
  }

  Future<void> scheduleEventReminder(Event event) async {
    final eventTime = event.eventDate.toDate();
    final oneDayBefore = eventTime.subtract(const Duration(days: 1));

    if (oneDayBefore.isAfter(DateTime.now())) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        event.id.hashCode,
        'Upcoming Event Reminder',
        '${event.title} is happening tomorrow!',
        tz.TZDateTime.from(oneDayBefore, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'event_reminders_channel',
            'Event Reminders',
            channelDescription: 'Reminders for upcoming events.',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // uiLocalNotificationDateInterpretation:
        //     UILocalNotificationDateInterpretation.absoluteTime,
      );
      log("Scheduled reminder for event ${event.title}");
    }
  }

  Future<void> scheduleEventReminders(List<Event> events) async {
    for (final event in events) {
      await scheduleEventReminder(event);
    }
  }

  Future<void> cancelEventReminder(String eventId) async {
    await _flutterLocalNotificationsPlugin.cancel(eventId.hashCode);
  }

  Future<void> cancelAllEventReminders() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    log("Cancelled all event reminders.");
  }
}
