import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/edit_user.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/levels/chapters.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/levels/district.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/levels/level_members.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/levels/zones.dart';
import 'package:hef/src/interface/screens/web_view_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget customDrawer({required UserModel user, required BuildContext context}) {
  NavigationService navigationService = NavigationService();
  return SafeArea(
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drawer Header
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(scale: 5, 'assets/pngs/splash_logo.png'),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            decoration: const BoxDecoration(color: Color(0xFFF7F7FC)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(user.image ?? ''),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name ?? '',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.phone ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        navigationService.pushNamed('EditUser');
                      },
                      icon: SvgPicture.asset('assets/svg/icons/edit_icon.svg')),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          // Drawer Items

          _buildDrawerItem(
            icon: 'assets/svg/icons/analytics.svg',
            label: 'Analytics',
            onTap: () {
              navigationService.pushNamed('AnalyticsPage');
            },
          ),
          if (user.isAdmin ?? false)
            _buildDrawerItem(
              icon: 'assets/svg/icons/levels.svg',
              label: 'Levels',
              onTap: () {
                switch (user.adminType) {
                  case 'State Admin':
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ZonesPage(
                                  stateId: user.levelId ?? '',
                                  stateName: user.levelName ?? '',
                                )));
                    break;
                  case 'Zone Admin':
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DistrictsPage(
                                  zoneId: user.levelId ?? '',
                                  zoneName: user.levelName ?? '',
                                )));
                    break;
                  case 'District Admin':
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChaptersPage(
                                  districtId: user.levelId ?? '',
                                  districtName: user.levelName ?? '',
                                )));
                    break;
                  case 'Chapter Admin':
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LevelMembers(
                                  chapterId: user.levelId ?? '',
                                  chapterName: user.levelName ?? '',
                                )));
                    break;
                  default:
                }
              },
            ),

          _buildDrawerItem(
            icon: 'assets/svg/icons/my_products.svg',
            label: 'My Products',
            onTap: () {
              navigationService.pushNamed('MyProducts');
            },
          ),
          _buildDrawerItem(
            icon: 'assets/svg/icons/my_requirements.svg',
            label: 'My Businesses',
            onTap: () {
              navigationService.pushNamed('MyBusinesses');
            },
          ),
          _buildDrawerItem(
            icon: 'assets/svg/icons/requestnfc.svg',
            label: 'Request NFC',
            onTap: () {
              navigationService.pushNamed('RequestNFC');
            },
          ),
          if (user.phone != '+919645398555')
            _buildDrawerItem(
              icon: 'assets/svg/icons/my_subscription.svg',
              label: 'My Subscription',
              onTap: () {
                navigationService.pushNamed('MySubscriptionPage');
              },
            ),

          _buildDrawerItem(
            icon: 'assets/svg/icons/my_reviews.svg',
            label: 'My Reviews',
            onTap: () {
              navigationService.pushNamed('MyReviews');
            },
          ),

          _buildDrawerItem(
            icon: 'assets/svg/icons/my_events.svg',
            label: 'My Events',
            onTap: () {
              navigationService.pushNamed('MyEvents');
            },
          ),
          // _buildDrawerItem(
          //   icon: 'assets/svg/icons/my_transactions.svg',
          //   label: 'My Transactions',
          //   onTap: () {},
          // ),

          SizedBox(
            height: 40,
          ),
          if (user.phone != '+919645398555')
            _buildDrawerItem(
              icon: 'assets/svg/icons/about_us.svg',
              label: 'About Us',
              onTap: () {
                navigationService.pushNamed('AboutPage');
              },
            ),

          _buildDrawerItem(
            icon: 'assets/svg/icons/terms.svg',
            label: 'Terms & Conditions',
            onTap: () {
              navigationService.pushNamed('Terms');
            },
          ),

          _buildDrawerItem(
            icon: 'assets/svg/icons/privacy_policy.svg',
            label: 'Privacy Policy',
            onTap: () {
              navigationService.pushNamed('PrivacyPolicy');
            },
          ),
          _buildDrawerItem(
            icon: 'assets/svg/icons/logout.svg',
            label: 'Logout',
            onTap: () async {
              final SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              preferences.remove('token');
              preferences.remove('id');

              navigationService.pushNamedAndRemoveUntil('PhoneNumber');
              await editUser({
                "fcm":""
              });
            },
          ),
          _buildDrawerItem(
            icon: 'assets/svg/icons/phone_icon.svg',
            label: 'Change Number',
            onTap: () {
              navigationService.pushNamed('ChangeNumber');
            },
          ),
          _buildDrawerItem(
            icon: 'assets/svg/icons/delete_account.svg',
            label: 'Delete Account',
            textColor: kRed,
            onTap: () {},
          ),
          // Footer
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WebViewScreen(
                            color: Colors.blue,
                            url: 'https://www.skybertech.com/',
                            title: 'Skybertech',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kGrey),
                          color: const Color.fromARGB(255, 246, 246, 246)),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10, left: 22, right: 22),
                            child: Text(
                              'Powered by',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                          Image.asset(
                            scale: 15,
                            'assets/pngs/skybertechlogo.png',
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WebViewScreen(
                            color: Colors.deepPurpleAccent,
                            url: 'https://www.acutendeavors.com/',
                            title: 'ACUTE ENDEAVORS',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kGrey),
                          color: const Color.fromARGB(255, 246, 246, 246)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2, bottom: 3),
                              child: Text(
                                'Developed by',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 7),
                              child: Image.asset(
                                scale: 25,
                                'assets/pngs/acutelogo.png',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDrawerItem({
  required String icon,
  required String label,
  VoidCallback? onTap,
  Color textColor = Colors.black,
}) {
  return ListTile(
    leading: SvgPicture.asset(
      icon,
      height: 24,
      color: Colors.orange,
    ),
    title: Text(
      label,
      style: TextStyle(fontSize: 16, color: textColor),
    ),
    onTap: onTap,
  );
}
