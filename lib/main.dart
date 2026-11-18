import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/firebase_options.dart';

import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/data/services/notification_service.dart';
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:hef/src/data/router/router.dart' as router;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:hef/src/data/utils/secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("HEF: Starting app initialization...");

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("HEF: Firebase initialized");
  } catch (e) {
    debugPrint("HEF: Firebase init error: $e");
  }

  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.debug,
    );
    debugPrint("HEF: AppCheck activated");
  } catch (e) {
    debugPrint("HEF: AppCheck error: $e");
  }

  try {
    await loadSecureData();
    debugPrint("HEF: Secure data loaded");
  } catch (e) {
    debugPrint("HEF: Secure data error: $e");
  }

  try {
    await dotenv.load(fileName: ".env");
    debugPrint("HEF: Dotenv loaded");
  } catch (e) {
    debugPrint("HEF: Dotenv error: $e");
  }

  debugPrint("HEF: Calling runApp...");
  runApp(ProviderScope(child: MyApp()));

  try {
    NotificationService().initialize().then((_) {
      debugPrint("HEF: NotificationService initialized");
    }).catchError((e) {
      debugPrint("HEF: NotificationService error: $e");
    });
  } catch (e) {
    debugPrint("HEF: NotificationService trigger error: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      scaffoldMessengerKey: SnackbarService.scaffoldMessengerKey,
      onGenerateRoute: router.generateRoute,
      initialRoute: 'Splash',
      title: 'HEF',
      theme: ThemeData(
        fontFamily: kFamilyName,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
    );
  }
}
