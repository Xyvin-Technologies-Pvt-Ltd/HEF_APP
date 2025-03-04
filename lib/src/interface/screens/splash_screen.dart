import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/models/app_version_model.dart';
import 'package:hef/src/data/services/launch_url.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/main.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/services/getFcmToken.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';
import 'package:flutter_upgrade_version/models/package_info.dart';

class SplashScreen extends ConsumerStatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool isAppUpdateRequired = false;

  @override
  void initState() {
    super.initState();
    initialize();
    checkAppVersion(context).then((_) {
      if (!isAppUpdateRequired) {
    initialize();
    }
    });
    getToken();
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print("New FCM Token: $newToken");
      // Save or send the new token to your server
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        if (Platform.isAndroid) {
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
            0, // Notification ID
            message.notification?.title,
            message.notification?.body,
            platformChannelSpecifics,
          );
        }
        // No need for local notifications on iOS in foreground
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened: ${message.data}');
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print('Notification clicked when app was terminated');
      }
    });
  }

  Future<void> checkAppVersion(context) async {
    log('Checking app version...');
    final response = await http.get(Uri.parse('$baseUrl/user/app-version'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final appVersionResponse = AppVersionResponse.fromJson(jsonResponse);
      await checkForUpdate(appVersionResponse, context);
    } else {
      log('Failed to fetch app version');
      throw Exception('Failed to load app version');
    }
  }

  Future<void> checkForUpdate(AppVersionResponse response, context) async {
    PackageInfo packageInfo = await PackageManager.getPackageInfo();
    final currentVersion = int.parse(packageInfo.version.split('.').join());
    log('Current version: $currentVersion');
    log('New version: ${response.version}');

    if (currentVersion < response.version && response.force) {
      // Pause initialization and show update dialog
      isAppUpdateRequired = true;
      showUpdateDialog(response, context);
    }
  }

  void showUpdateDialog(AppVersionResponse response, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Force update requirement
      builder: (context) => AlertDialog(
        title: Text('Update Required'),
        content: Text(response.updateMessage),
        actions: [
          TextButton(
            onPressed: () {
              // Redirect to app store
              launchURL(response.applink);
            },
            child: Text('Update Now'),
          ),
        ],
      ),
    );
  }

  Future<void> initialize() async {
    NavigationService navigationSerivce = NavigationService();
    await checkLoggedIn();
    Timer(Duration(seconds: 2), () {
      if (!isAppUpdateRequired) {
        print('Logged in : $LoggedIn');
        if (LoggedIn) {
          navigationSerivce.pushNamedReplacement('MainPage');
        } else {
          navigationSerivce.pushNamedReplacement('PhoneNumber');
        }
      }
    });
  }

  Future<void> checkLoggedIn() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? savedtoken = preferences.getString('token');
    String? savedId = preferences.getString('id');
    log('token:$savedtoken');
    log('userId:$savedId');
    if (savedtoken != null && savedtoken.isNotEmpty && savedId != null) {
      setState(() {
        LoggedIn = true;
        token = savedtoken;
        id = savedId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kScaffoldColor,
        body: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/svg/images/flower_full.svg',
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/pngs/splash_logo.png',
              ),
            ),
          ],
        ));
  }
}
