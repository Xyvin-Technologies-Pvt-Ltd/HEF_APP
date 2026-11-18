import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hef/src/data/globals.dart';


Future<void> getToken() async {
  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission for iOS devices (optional)
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
      // Fetch the FCM token with timeout to prevent hanging on simulators
      String? token = await messaging.getToken().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          print("FCM Token timeout (simulator likely has no APNs token)");
          return null;
        },
      );
      fcmToken = token ?? '';
      print("FCM Token: $token");
    } else {
      print('User declined or has not accepted permission');
    }
  } catch (e) {
    print('Error in getToken: $e');
  }
}