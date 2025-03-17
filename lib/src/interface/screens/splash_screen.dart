import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/models/app_version_model.dart';
import 'package:hef/src/data/services/deep_link_service.dart';
import 'package:hef/src/data/services/launch_url.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
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
  bool hasVersionCheckError = false;
  String errorMessage = '';
  final DeepLinkService _deepLinkService = DeepLinkService();
  @override
  void initState() {
    super.initState();
    checkAppVersion(context).then((_) {
      if (!isAppUpdateRequired && !hasVersionCheckError) {
        initialize();
      }
    });
    getToken();
  }

  Future<void> checkAppVersion(context) async {
    try {
      log('Checking app version...');
      final response = await http.get(Uri.parse('$baseUrl/user/app-version'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final appVersionResponse = AppVersionResponse.fromJson(jsonResponse);
        await checkForUpdate(appVersionResponse, context);
      } else {
        log('Failed to fetch app version: ${response.statusCode}');
        setState(() {
          hasVersionCheckError = true;
          errorMessage = 'Server is down please try again later';
        });
      }
    } catch (e) {
      log('Error checking app version: $e');
      setState(() {
        hasVersionCheckError = true;
        errorMessage =
            'An error occurred while checking for updates. Please try again.';
      });
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

  Future<void> retryVersionCheck() async {
    setState(() {
      hasVersionCheckError = false;
      errorMessage = '';
    });
    await checkAppVersion(context);
  }

  Future<void> initialize() async {
    NavigationService navigationService = NavigationService();
    await checktoken();
    Timer(Duration(seconds: 2), () {
      if (!isAppUpdateRequired) {
        print('Logged in : $LoggedIn');
        if (LoggedIn) {
          // Check for pending deep link
          final pendingDeepLink = _deepLinkService.pendingDeepLink;
          if (pendingDeepLink != null) {
            navigationService.pushNamedReplacement('MainPage').then((_) {
              // Handle the deep link after main page is loaded
              _deepLinkService.handleDeepLink(pendingDeepLink);
              _deepLinkService.clearPendingDeepLink();
            });
          } else {
        navigationService.pushNamedReplacement( 'MainPage');
          }
        } else {
      navigationService.pushNamedReplacement( 'PhoneNumber');
        }
      }
    });
  }

  Future<void> checktoken() async {
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
          if (hasVersionCheckError)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 16),
                    // customButton(label: 'Retry', onPressed: retryVersionCheck)
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
