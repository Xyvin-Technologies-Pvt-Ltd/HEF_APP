import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/notifiers/active_chat_tracker.dart';
import 'package:hef/src/data/services/deep_link_service.dart';

const String _androidChatChannelId = 'hef_chat_messages';
const String _androidChatChannelName = 'Chat Messages';

/// Minimal background handler. When FCM includes a `notification` block the
/// OS already shows the tray item — avoid duplicating it here.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background FCM message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final DeepLinkService _deepLinkService = DeepLinkService();
  final Set<String> _recentMessageIds = <String>{};
  bool _channelCreated = false;

  Future<void> initialize() async {
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosInitializationSetting =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const InitializationSettings initSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: iosInitializationSetting,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _handleNotificationTap,
      ).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('flutterLocalNotificationsPlugin.initialize timed out');
          return true;
        },
      );

      await _ensureAndroidChannel();

      // Keep iOS from auto-presenting FCM banners in foreground so we can
      // suppress notifications for the currently open conversation.
      try {
        await FirebaseMessaging.instance
            .setForegroundNotificationPresentationOptions(
          alert: false,
          badge: true,
          sound: false,
        ).timeout(const Duration(seconds: 2));
      } catch (e) {
        debugPrint('setForegroundNotificationPresentationOptions error: $e');
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        debugPrint('New FCM Token: $newToken');
        fcmToken = newToken;
      });

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      await _handleInitialMessage().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint('_handleInitialMessage timed out');
        },
      );
    } catch (e) {
      debugPrint('Notification initialization error: $e');
    }
  }

  Future<void> _ensureAndroidChannel() async {
    if (_channelCreated || !Platform.isAndroid) return;
    const channel = AndroidNotificationChannel(
      _androidChatChannelId,
      _androidChatChannelName,
      description: 'Notifications for new chat messages',
      importance: Importance.max,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    _channelCreated = true;
  }

  bool _isDuplicate(RemoteMessage message) {
    final key = message.messageId ??
        '${message.data['screen']}_${message.data['id']}_${message.notification?.body}';
    if (_recentMessageIds.contains(key)) return true;
    _recentMessageIds.add(key);
    if (_recentMessageIds.length > 50) {
      _recentMessageIds.remove(_recentMessageIds.first);
    }
    return false;
  }

  bool _shouldSuppressChatNotification(Map<String, dynamic> data) {
    final screen = data['screen']?.toString();
    if (screen != 'chat' && screen != 'group_chat') return false;

    final chatId = data['id']?.toString();
    final senderId = data['senderId']?.toString() ??
        data['from']?.toString() ??
        data['sender']?.toString();

    if (senderId != null &&
        senderId.isNotEmpty &&
        id.isNotEmpty &&
        senderId == id) {
      return true;
    }

    final isGroup = screen == 'group_chat' ||
        data['isGroup'] == true ||
        data['isGroup']?.toString().toLowerCase() == 'true';

    return ActiveChatTracker.instance.isViewingChat(chatId, isGroup: isGroup);
  }

  String _deepLinkFromMessage(RemoteMessage message) {
    final screen = message.data['screen']?.toString() ??
        message.data['tag']?.toString() ??
        'notification';
    final idValue = message.data['id']?.toString();
    return _deepLinkService.getDeepLinkPath(
      screen.isEmpty ? 'notification' : screen,
      id: idValue,
    );
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    log('Notification received: ${message.data}');
    try {
      if (_isDuplicate(message)) return;
      if (_shouldSuppressChatNotification(message.data)) {
        debugPrint('Suppressed chat notification for open conversation');
        return;
      }

      if (message.notification == null) return;

      await _ensureAndroidChannel();

      final deepLink = _deepLinkFromMessage(message);

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        _androidChatChannelId,
        _androidChatChannelName,
        channelDescription: 'Notifications for new chat messages',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final notifId = message.messageId?.hashCode ?? message.hashCode;

      await flutterLocalNotificationsPlugin.show(
        notifId,
        message.notification?.title,
        message.notification?.body,
        platformDetails,
        payload: deepLink,
      );
    } catch (e) {
      debugPrint('Foreground message handling error: $e');
    }
  }

  void _queueOrNavigate(String? deepLink) {
    final link = (deepLink == null || deepLink.isEmpty)
        ? _deepLinkService.getDeepLinkPath('notification')
        : deepLink;
    final uri = Uri.parse(link);
    if (!DeepLinkService.hasNavigatorOverlay()) {
      _deepLinkService.setPendingDeepLink(uri);
      return;
    }
    _deepLinkService.handleDeepLink(uri);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    try {
      debugPrint('Notification opened app: ${message.data}');
      _queueOrNavigate(_deepLinkFromMessage(message));
    } catch (e) {
      debugPrint('Message opened app handling error: $e');
    }
  }

  void _handleNotificationTap(NotificationResponse response) {
    try {
      debugPrint('Local notification tap payload: ${response.payload}');
      _queueOrNavigate(response.payload);
    } catch (e) {
      debugPrint('Notification tap handling error: $e');
    }
  }

  Future<void> _handleInitialMessage() async {
    try {
      // Cold-start from a local notification (foreground-shown tray item).
      final launchDetails = await flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp == true &&
          (launchDetails?.notificationResponse?.payload?.isNotEmpty ??
              false)) {
        debugPrint(
            'Queuing local-notification launch deep link: ${launchDetails!.notificationResponse!.payload}');
        _deepLinkService.setPendingDeepLink(
          Uri.parse(launchDetails.notificationResponse!.payload!),
        );
        return;
      }

      // Cold-start from an FCM system notification.
      final RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage == null) return;

      debugPrint('Queuing initial FCM deep link: ${initialMessage.data}');
      // Always defer cold-start until Splash/auth completes.
      _deepLinkService.setPendingDeepLink(
        Uri.parse(_deepLinkFromMessage(initialMessage)),
      );
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
