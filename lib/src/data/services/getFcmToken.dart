
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hef/src/data/globals.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> getToken(BuildContext context) async {
  final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
  final notificationStatus = await Permission.notification.status;

  if (isIOS || notificationStatus.isGranted) {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM token (common for both platforms)
      String? token = await messaging.getToken();
      fcmToken = token ?? '';
      print("FCM Token: $token");

      if (isIOS) {
        // Get APNs token (iOS-specific)
        String? apnsToken = await messaging.getAPNSToken();
        print("APNs Token: $apnsToken");
        // Optionally: send APNs token to your server if needed
      }
    } else {
      print('User declined or has not accepted permission');
    }
  } else if (notificationStatus.isDenied || notificationStatus.isPermanentlyDenied) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Notifications Disabled"),
        content: Text(
          "Notifications are disabled. You can enable them later in settings."
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Continue"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text("Open Settings"),
          ),
        ],
      ),
    );
  }
}
