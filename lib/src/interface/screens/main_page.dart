import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hef/src/data/api_routes/chat_api/chat_api.dart';
import 'package:hef/src/data/api_routes/levels_api/levels_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:hef/src/data/router/nav_router.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/components/shimmers/promotion_shimmers.dart';
import 'package:hef/src/interface/screens/main_pages/admin/allocate_member.dart';
import 'package:hef/src/interface/screens/main_pages/profile_page.dart';
import 'package:hef/src/interface/screens/main_pages/business_page.dart';
import 'package:hef/src/interface/screens/main_pages/chat_page.dart';
import 'package:hef/src/interface/screens/main_pages/home_page.dart';
import 'package:hef/src/interface/screens/main_pages/login_page.dart';
import 'package:hef/src/interface/screens/main_pages/news_page.dart';
import 'package:hef/src/interface/screens/no_chapter_condition_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IconResolver extends StatelessWidget {
  final String iconPath;
  final Color color;
  final double height;
  final double width;

  const IconResolver({
    Key? key,
    required this.iconPath,
    required this.color,
    this.height = 24,
    this.width = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (iconPath.startsWith('http') || iconPath.startsWith('https')) {
      return Image.network(
        iconPath,
        // color: color,
        height: height,
        width: width,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.error);
        },
      );
    } else {
      return SvgPicture.asset(
        iconPath,
        // color: color,
        height: height,
        width: width,
      );
    }
  }
}

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  late final webSocketClient;

  @override
  void initState() {
    super.initState();
    webSocketClient = ref.read(socketIoClientProvider);
    webSocketClient.connect(id, ref);
  }

  @override
  void dispose() {
    super.dispose();
  }

  static List<Widget> _widgetOptions = <Widget>[];

  void _onItemTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      ref.read(currentNewsIndexProvider.notifier).state = 0;
      // _selectedIndex = index;
      ref.read(selectedIndexProvider.notifier).updateIndex(index);
    });
  }

  List<String> _inactiveIcons = [];
  List<String> _activeIcons = [];
  Future<void> _initialize({required UserModel user}) async {
    _widgetOptions = <Widget>[
      HomePage(
        user: user,
      ),
      BusinessPage(),
      ProfilePage(user: user),
      NewsPage(),
      PeoplePage(),
    ];
    _activeIcons = [
      'assets/svg/icons/active_home.svg',
      'assets/svg/icons/active_business.svg',
      'assets/svg/icons/active_analytics.svg',
      'assets/svg/icons/active_news.svg',
      'assets/svg/icons/active_chat.svg',
    ];
    _inactiveIcons = [
      'assets/svg/icons/inactive_home.svg',
      'assets/svg/icons/inactive_business.svg',
      'assets/svg/icons/inactive_analytics.svg',
      'assets/svg/icons/inactive_news.svg',
      'assets/svg/icons/inactive_chat.svg',
    ];
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('id', user.uid!);
    id = preferences.getString('id') ?? '';
    log('main page user id:$id');
  }

  Widget _buildStatusPage(String status, UserModel user) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    switch (status.toLowerCase()) {
      case 'active':
        if (user.chapter != null && user.chapter != '') {
          return Scaffold(
            body: Center(
              child: _widgetOptions.elementAt(selectedIndex),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: List.generate(5, (index) {
                return BottomNavigationBarItem(
                  backgroundColor: Colors.white,
                  icon: index == 2 // Assuming profile is the third item
                      ? user.image != null && user.image != ''
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                user.image ?? '',
                              ),
                              radius: 15,
                            )
                          : Image.asset(
                              'assets/pngs/dummy_person_small.png',
                              scale: 1,
                            )
                      : IconResolver(
                          iconPath: _inactiveIcons[index],
                          color: selectedIndex == index
                              ? kPrimaryColor
                              : Colors.grey,
                        ),
                  activeIcon: index == 2
                      ? user.image != null && user.image != ''
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                user.image ?? '',
                              ),
                              radius: 15,
                            )
                          : Image.asset(
                              'assets/pngs/dummy_person_small.png',
                              scale: 1.5,
                            )
                      : IconResolver(
                          iconPath: _activeIcons[index], color: kPrimaryColor),
                  label: ['Home', 'Business', 'Profile', 'News', 'Chat'][index],
                );
              }),
              currentIndex: selectedIndex,
              selectedItemColor: kPrimaryColor,
              unselectedItemColor: Colors.grey,
              onTap: (index) {
                HapticFeedback.selectionClick();
                _onItemTapped(index);
              },
              showUnselectedLabels: true,
            ),
          );
        } else {
          return NoChapterConditionPage(user: user);
        }
      case 'inactive':
        return Scaffold(
          body: Center(
            child: Container(
              padding: EdgeInsets.all(20.0),
              margin: EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(
                  color: Colors.orange,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 48,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Your account is currently Inactive",
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Please complete your profile setup",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  customButton(
                    label: "Upload payment",
                    onPressed: () {
                      NavigationService navigationService = NavigationService();
                      navigationService.pushNamed('MySubscriptionPage');
                    },
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      final SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      preferences.remove('token');
                      preferences.remove('id');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhoneNumberScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Logout',
                      style: TextStyle(color: Colors.orange[800]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      case 'suspended':
        return Scaffold(
          body: Center(
            child: Container(
              padding: EdgeInsets.all(20.0),
              margin: EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(
                  color: kRed,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.block,
                    color: Colors.red,
                    size: 48,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Your account is Suspended",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Please contact Admin for more information",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () async {
                      final SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      preferences.remove('token');
                      preferences.remove('id');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhoneNumberScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      case 'blocked':
        return Scaffold(
          body: Center(
            child: Container(
              padding: EdgeInsets.all(20.0),
              margin: EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(
                  color: kRed,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.gpp_bad,
                    color: Colors.red,
                    size: 48,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Your account has been Blocked",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Please contact Admin for assistance",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () async {
                      final SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      preferences.remove('token');
                      preferences.remove('id');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhoneNumberScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      case 'deleted':
        // Immediately navigate to PhoneNumberScreen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PhoneNumberScreen(),
            ),
          );
        });
        // Return a loading screen while navigation occurs
        return Scaffold(
          body: Center(
            child: LoadingAnimation(),
          ),
        );

      default:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PhoneNumberScreen(),
            ),
          );
        });
        // Return a loading screen while navigation occurs
        return Scaffold(
          body: Center(
            child: LoadingAnimation(),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final selectedIndex = ref.watch(selectedIndexProvider);
      final asyncUser = ref.watch(userProvider);

      return asyncUser.when(
        loading: () {
          log('im inside details main page loading');
          return Scaffold(
              backgroundColor: kScaffoldColor,
              body: buildShimmerPromotionsColumn(context: context));
        },
        error: (error, stackTrace) {
          log('im inside details main page error $error $stackTrace');
          return PhoneNumberScreen();
        },
        data: (user) {
          subscriptionType = user.subscription ?? 'free';
          _initialize(user: user);
          return PopScope(
            canPop: selectedIndex != 0 ? false : true,
            onPopInvokedWithResult: (didPop, result) {
              log('im inside mainpage popscope');
              if (selectedIndex != 0) {
                ref.read(selectedIndexProvider.notifier).updateIndex(0);
              }
            },
            child: _buildStatusPage(user.status ?? 'unknown', user),
          );
        },
      );
    });
  }
}
