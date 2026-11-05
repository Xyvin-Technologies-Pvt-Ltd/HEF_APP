import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hef/src/data/api_routes/chat_api/chat_api.dart';
import 'package:hef/src/data/api_routes/levels_api/levels_api.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/edit_user.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:hef/src/data/router/nav_router.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/data/utils/secure_storage.dart';
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
import 'package:hef/src/interface/screens/main_pages/menuPages/analytics/analytics.dart';
import 'package:hef/src/interface/screens/no_chapter_condition_page.dart';

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
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
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
  late final SocketIoClientService webSocketClient;

  @override
  void initState() {
    super.initState();
    webSocketClient = ref.read(socketIoClientProvider);
    webSocketClient.connect(id, ref);
  }

  @override
  void dispose() {
    webSocketClient.disconnect();
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

  Future<void> _initialize({required UserModel user}) async {
    _widgetOptions = <Widget>[
      HomePage(user: user),
      BusinessPage(),
      PeoplePage(),
      const AnalyticsPage(
        initialTab: 'sent',
        requestType: 'One v One Meeting',
      ),
      ProfilePage(user: user),
    ];
    await SecureStorage.write('id', user.uid ?? '');
    id = user.uid ?? '';
    log('main page user id:$id');
  }

  Widget _navigationIcon(
    int index, {
    required bool selected,
    required double iconSize,
    required Color iconColor,
  }) {
    if (index == 2) {
      return Icon(Icons.groups_outlined, color: iconColor, size: iconSize);
    }
    if (index == 3) {
      return Icon(Icons.swap_horiz, color: iconColor, size: iconSize);
    }
    if (index == 4) {
      return Icon(Icons.person_outline, color: iconColor, size: iconSize);
    }

    final asset = selected
        ? 'assets/svg/icons/active_${index == 0 ? 'home' : 'business'}.svg'
        : 'assets/svg/icons/inactive_${index == 0 ? 'home' : 'business'}.svg';
    return SvgPicture.asset(
      asset,
      height: iconSize,
      width: iconSize,
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
    );
  }

  Widget _buildBottomNavigationBar(int selectedIndex) {
    const inactiveColor = Color(0xFF929CAA);
    const selectedColor = Color(0xFFFF6D00);
    const labels = [
      'Home',
      'Business',
      'Community',
      '1-1 Meetings',
      'Profile',
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final cornerRadius = width * (36 / 390);

        return Material(
          color: Colors.white,
          elevation: 8,
          shadowColor: Colors.black26,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(cornerRadius)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                children: List.generate(labels.length, (index) {
                  final isSelected = index == selectedIndex;
                  final color = isSelected ? selectedColor : inactiveColor;
                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _onItemTapped(index);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _navigationIcon(
                            index,
                            selected: isSelected,
                            iconSize: 24,
                            iconColor: color,
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                labels[index],
                                maxLines: 1,
                                style: TextStyle(
                                  color: color,
                                  fontFamily: 'Helvetica',
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusPage(String status, UserModel user) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    switch (status.toLowerCase()) {
      case 'active':
        return Scaffold(
          backgroundColor: Colors.white,
          extendBody: true,
          body: _widgetOptions.elementAt(selectedIndex),
          bottomNavigationBar: _buildBottomNavigationBar(selectedIndex),
        );

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
                      await SecureStorage.delete('token');
                      await SecureStorage.delete('id');

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhoneNumberScreen(),
                        ),
                      );
                      await editUser(
                          {"fcm": "", "name": user.name, "phone": user.phone});
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
                      await SecureStorage.delete('token');
                      await SecureStorage.delete('id');

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
                      await SecureStorage.delete('token');
                      await SecureStorage.delete('id');

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
          if (user.fcm == null || user.fcm == '') {
            editUser({"fcm": fcmToken, "name": user.name, "phone": user.phone});
          }
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
