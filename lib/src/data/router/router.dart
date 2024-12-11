import 'package:flutter/material.dart';
import 'package:hef/src/data/models/events_model.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/interface/screens/main_page.dart';
import 'package:hef/src/interface/screens/main_pages/admin/allocate_member.dart';
import 'package:hef/src/interface/screens/main_pages/admin/member_creation.dart';
import 'package:hef/src/interface/screens/main_pages/event/event_member_list.dart';
import 'package:hef/src/interface/screens/main_pages/event/view_more_event.dart';
import 'package:hef/src/interface/screens/main_pages/login_page.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/add_product.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/analytics/analytics.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/analytics/send_analytic_req.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/levels/chapters.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/levels/district.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/levels/level_members.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/levels/profile_analytics.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/levels/states.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/levels/zones.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/my_businesses.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/my_events.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/my_products.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/my_reviews.dart';
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
    case 'MemberAllocation':
      UserModel newUser = settings?.arguments as UserModel;
      return MaterialPageRoute(
          builder: (context) => AllocateMember(
                newUser: newUser,
              ));
    case 'EventMemberList':
      Event event = settings?.arguments as Event;
      return MaterialPageRoute(
          builder: (context) => EventMemberList(
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
    case 'MyProducts':
      return MaterialPageRoute(builder: (context) => MyProductPage());
    case 'EnterProductsPage':
      return MaterialPageRoute(builder: (context) => EnterProductsPage());
    case 'MyBusinesses':
      return MaterialPageRoute(builder: (context) => MyBusinessesPage());
    case 'AnalyticsPage':
      return MaterialPageRoute(builder: (context) => AnalyticsPage());
    case 'SendAnalyticRequest':
      return MaterialPageRoute(builder: (context) => SendAnalyticRequestPage());

    case 'RequestNFC':
      return MaterialPageRoute(builder: (context) => RequestNFCPage());
    case 'MyReviews':
      return MaterialPageRoute(builder: (context) => MyReviewsPage());
    case 'States':
      return MaterialPageRoute(builder: (context) => StatesPage());
    case 'Zones':
      String stateId = settings?.arguments as String;
      return MaterialPageRoute(
          builder: (context) => ZonesPage(
                stateId: stateId,
              ));
    case 'Districts':
      String zoneId = settings?.arguments as String;
      return MaterialPageRoute(
          builder: (context) => DistrictsPage(
                zoneId: zoneId,
              ));
    case 'Chapters':
      String districtId = settings?.arguments as String;
      return MaterialPageRoute(
          builder: (context) => ChaptersPage(
                districtId: districtId,
              ));
    case 'LevelMembers':
      String chapterId = settings?.arguments as String;
      return MaterialPageRoute(
          builder: (context) => LevelMembers(
                chapterId: chapterId,
              ));
    case 'ProfileAnalytics':
      UserModel user = settings?.arguments as UserModel;
      return MaterialPageRoute(
          builder: (context) => ProfileAnalyticsPage(
                user: user,
              ));
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
