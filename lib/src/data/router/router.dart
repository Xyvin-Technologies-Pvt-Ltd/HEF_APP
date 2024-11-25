import 'package:flutter/material.dart';
import 'package:hef/src/interface/screens/main_page.dart';
import 'package:hef/src/interface/screens/main_pages/login_page.dart';

import 'package:hef/src/interface/screens/splash_screen.dart';

Route<dynamic> generateRoute(RouteSettings? settings) {
  switch (settings?.name) {
    case 'Splash':
      return MaterialPageRoute(builder: (context) =>  SplashScreen());
    case 'PhoneNumber':
      return MaterialPageRoute(builder: (context) =>  PhoneNumberScreen());
    case 'MainPage':
      return MaterialPageRoute(builder: (context) => const MainPage());
 default:
      return MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(
            child: Text('No path for ${settings?.name}'),
          ),
        ),
      );
  }
}
