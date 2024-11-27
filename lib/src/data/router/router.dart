import 'package:flutter/material.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/interface/screens/main_page.dart';
import 'package:hef/src/interface/screens/main_pages/login_page.dart';
import 'package:hef/src/interface/screens/main_pages/profile/card.dart';

import 'package:hef/src/interface/screens/splash_screen.dart';

Route<dynamic> generateRoute(RouteSettings? settings) {
  switch (settings?.name) {
    case 'Splash':
      return MaterialPageRoute(builder: (context) =>  SplashScreen());
    case 'PhoneNumber':
      return MaterialPageRoute(builder: (context) =>  PhoneNumberScreen());
    case 'Otp':
    String phone = settings?.arguments as String;
      return MaterialPageRoute(builder: (context) =>  OTPScreen(phone: phone,));
    case 'MainPage':
      return MaterialPageRoute(builder: (context) => const MainPage());
    case 'ProfileCompletion':
      return MaterialPageRoute(builder: (context) =>  const ProfileCompletionScreen());
    case 'Card':
        UserModel user = settings?.arguments as UserModel;
      return MaterialPageRoute(builder: (context) =>   ProfileCard(user:user ,));
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
