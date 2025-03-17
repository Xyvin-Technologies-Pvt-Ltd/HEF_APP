import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hef/src/data/services/deep_link_service.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final DeepLinkService _deepLinkService = DeepLinkService();

  Future<void> initialize() async {
    try {
      // Initialize local notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosInitializationSetting =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const InitializationSettings initSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: iosInitializationSetting);

      await flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _handleNotificationTap,
      );

      // // Request notification permissions
      // await _requestNotificationPermissions();

      // Set up FCM handlers
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        debugPrint("New FCM Token: $newToken");
        // Save or send the new token to your server
      });

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      await _handleInitialMessage();
    } catch (e) {
      debugPrint('Notification initialization error: $e');
    }
  }

  // Future<void> _requestNotificationPermissions() async {
  //   if (Platform.isIOS) {
  //     await FirebaseMessaging.instance.requestPermission(
  //       alert: true,
  //       badge: true,
  //       sound: true,
  //     );
  //   }
  // }

  void _handleForegroundMessage(RemoteMessage message) {
    log("Notification recieved: ${message.data}");
    try {
      if (message.notification != null && Platform.isAndroid) {
        String? deepLink;
        if (message.data.containsKey('screen')) {
          final id = message.data['id'];
          deepLink = _deepLinkService.getDeepLinkPath(
            message.data['screen'],
            id: id,
          );
        }

        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );
        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        flutterLocalNotificationsPlugin.show(
          message.hashCode,
          message.notification?.title,
          message.notification?.body,
          platformChannelSpecifics,
          payload: deepLink,
        );
      }
    } catch (e) {
      debugPrint('Foreground message handling error: $e');
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    try {
      String? deepLink;
      if (message.data.containsKey('screen')) {
        final id = message.data['id'];
        deepLink =
            _deepLinkService.getDeepLinkPath(message.data['screen'], id: id);
      }

      if (deepLink != null) {
        _deepLinkService.handleDeepLink(Uri.parse(deepLink));
      }
    } catch (e) {
      debugPrint('Message opened app handling error: $e');
    }
  }

  void _handleNotificationTap(NotificationResponse response) {
    try {
      if (response.payload != null) {
        _deepLinkService.handleDeepLink(Uri.parse(response.payload!));
      }
    } catch (e) {
      debugPrint('Notification tap handling error: $e');
    }
  }

  Future<void> _handleInitialMessage() async {
    try {
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('Handling initial message');
        _handleMessageOpenedApp(initialMessage);
      }
    } catch (e) {
      debugPrint('Initial message handling error: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }
}
