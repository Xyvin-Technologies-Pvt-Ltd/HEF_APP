import 'package:flutter/material.dart';
import 'package:hef/src/data/models/events_model.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/interface/screens/main_page.dart';
import 'package:hef/src/interface/screens/main_pages/admin/member_creation.dart';
import 'package:hef/src/interface/screens/main_pages/event_page.dart/view_more_event.dart';
import 'package:hef/src/interface/screens/main_pages/login_page.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/my_businesses.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/my_events.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/request_nfc.dart';
import 'package:hef/src/interface/screens/main_pages/news_page.dart';
import 'package:hef/src/interface/screens/main_pages/profile/card.dart';
import 'package:hef/src/interface/screens/main_pages/profile/editUser.dart';
import 'package:hef/src/interface/screens/main_pages/profile/profile_preview.dart';

import 'package:hef/src/interface/screens/splash_screen.dart';

Route<dynamic> generateRoute(RouteSettings? settings) {
  switch (settings?.name) {
    case 'Splash':
      return MaterialPageRoute(builder: (context) => SplashScreen());
    case 'PhoneNumber':
      return MaterialPageRoute(builder: (context) => PhoneNumberScreen());
    case 'Otp':
      String phone = settings?.arguments as String;
      return MaterialPageRoute(
          builder: (context) => OTPScreen(
                phone: phone,
              ));
    case 'MainPage':
      return MaterialPageRoute(builder: (context) => const MainPage());
    case 'ProfileCompletion':
      return MaterialPageRoute(
          builder: (context) => const ProfileCompletionScreen());
    case 'Card':
      UserModel user = settings?.arguments as UserModel;
      return MaterialPageRoute(
          builder: (context) => ProfileCard(
                user: user,
              ));
    case 'ProfilePreview':
      UserModel user = settings?.arguments as UserModel;
      return MaterialPageRoute(
          builder: (context) => ProfilePreview(
                user: user,
              ));
    case 'ViewMoreEvent':
      Event event = settings?.arguments as Event;
      return MaterialPageRoute(
          builder: (context) => ViewMoreEventPage(
                event: event,
              ));
    case 'EditUser':
      return MaterialPageRoute(builder: (context) => EditUser());
    case 'News':
      return MaterialPageRoute(builder: (context) => NewsPage());
    case 'MemberCreation':
      return MaterialPageRoute(builder: (context) => MemberCreationPage());
    case 'MyEvents':
      return MaterialPageRoute(builder: (context) => MyEventsPage());
    case 'MyBusinesses':
      return MaterialPageRoute(builder: (context) => MyBusinessesPage());

    case 'RequestNFC':
      return MaterialPageRoute(builder: (context) => RequestNFCPage());
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
