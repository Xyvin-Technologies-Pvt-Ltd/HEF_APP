import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:hef/src/data/router/router.dart' as router;
void main() {
  runApp(const MyApp());
    runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(          navigatorKey: NavigationService.navigatorKey,
          scaffoldMessengerKey: SnackbarService.scaffoldMessengerKey,
          onGenerateRoute: router.generateRoute,
          initialRoute: 'Splash',
      title: 'Flutter Demo',
      theme: ThemeData(       fontFamily: kFamilyName,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
     
    );
  }
}
