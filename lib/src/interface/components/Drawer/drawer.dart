import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hef/src/data/constants/color_constants.dart';

Widget customDrawer() {
  return SafeArea(
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drawer Header
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/pngs/hef_logo.png'),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(color: Color(0xFFF7F7FC)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(
                      'assets/avatar.png'), // Update this to your image
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alexander',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '9865451265',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset('assets/svg/icons/edit_icon.svg')),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          // Drawer Items
          _buildDrawerItem(
            icon: 'assets/svg/icons/requestnfc.svg',
            label: 'Request NFC',
            onTap: () {},
          ),
          _buildDrawerItem(
            icon: 'assets/svg/icons/my_subscription.svg',
            label: 'My Subscription',
            onTap: () {},
          ),
          _buildDrawerItem(
            icon: 'assets/svg/icons/my_reviews.svg',
            label: 'My Reviews',
            onTap: () {},
          ),
          _buildDrawerItem(
            icon: 'assets/svg/icons/my_events.svg',
            label: 'My Events',
            onTap: () {},
          ),
          _buildDrawerItem(
            icon: 'assets/svg/icons/my_transactions.svg',
            label: 'My Transactions',
            onTap: () {},
          ),
          _buildDrawerItem(
            icon: 'assets/svg/icons/my_requirements.svg',
            label: 'My Requirements',
            onTap: () {},
          ),
          SizedBox(
            height: 40,
          ),
          _buildDrawerItem(
            icon: 'assets/svg/icons/about_us.svg',
            label: 'About Us',
            onTap: () {},
          ),
          _buildDrawerItem(
            icon: 'assets/svg/icons/terms.svg',
            label: 'Terms & Conditions',
            onTap: () {},
          ),
          _buildDrawerItem(
            icon: 'assets/svg/icons/privacy_policy.svg',
            label: 'Privacy Policy',
            onTap: () {},
          ),
          _buildDrawerItem(
            icon: 'assets/svg/icons/logout.svg',
            label: 'Logout',
            onTap: () {},
          ),
          _buildDrawerItem(
            icon: 'assets/svg/icons/delete_account.svg',
            label: 'Delete Account',
            textColor: kRed,
            onTap: () {},
          ),
          // Footer
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    'Powered by',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Image.asset(
                    'assets/pngs/xyvin.png',
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
