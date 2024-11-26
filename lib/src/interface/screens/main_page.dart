import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/screens/main_pages/analytics_page.dart';
import 'package:hef/src/interface/screens/main_pages/business_page.dart';
import 'package:hef/src/interface/screens/main_pages/chat_page.dart';
import 'package:hef/src/interface/screens/main_pages/home_page.dart';
import 'package:hef/src/interface/screens/main_pages/login_page.dart';
import 'package:hef/src/interface/screens/main_pages/news_page.dart';
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
        color: color,
        height: height,
        width: width,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.error);
        },
      );
    } else {
      return SvgPicture.asset(
        iconPath,
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
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[];

  void _onItemTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      // ref.read(currentNewsIndexProvider.notifier).state = 0;
      _selectedIndex = index;
    });
  }

  List<String> _inactiveIcons = [];
  List<String> _activeIcons = [];
  Future<void> _initialize() async {
    _widgetOptions = <Widget>[
      HomePage(),
      BusinessPage(),
      AnalyticsPage(),
      NewsPage(),
      ChatPage(),
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
  }

  @override
  Widget build(BuildContext context) {
    _initialize();
    return PopScope(
        canPop: _selectedIndex != 0 ? false : true,
        onPopInvokedWithResult: (didPop, result) {
          if (_selectedIndex != 0) {
            setState(() {
              _selectedIndex = 0;
            });
          }
        },
        child: Scaffold(
          body: Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: List.generate(5, (index) {
              return BottomNavigationBarItem(
                backgroundColor: Colors.white,
                icon: IconResolver(
                  iconPath: _inactiveIcons[index],
                  color: _selectedIndex == index
                      ? Colors.blue
                      : Colors.transparent,
                ),
                activeIcon: IconResolver(
                  iconPath: _activeIcons[index],
                  color: Color(0xFF004797),
                ),
                label: ['Home', 'Business', 'Profile', 'News', 'Chat'][index],
              );
            }),
            currentIndex: _selectedIndex,
            selectedItemColor: kPrimaryColor,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
            showUnselectedLabels: true,
          ),
        ));
  }
}
