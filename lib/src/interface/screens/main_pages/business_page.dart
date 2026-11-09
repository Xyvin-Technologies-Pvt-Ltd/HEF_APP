import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/notification_api/notification_api.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/dashboard_model.dart';
import 'package:hef/src/data/models/notification_model.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/interface/components/Drawer/drawer.dart';
import 'package:hef/src/interface/screens/main_pages/business_activity_page.dart';
import 'package:hef/src/interface/screens/main_pages/notification_page.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class BusinessPage extends ConsumerStatefulWidget {
  const BusinessPage({super.key});

  @override
  ConsumerState<BusinessPage> createState() => _BusinessPageState();
}

class _BusinessPageState extends ConsumerState<BusinessPage> {
  final _advancedDrawerController = AdvancedDrawerController();
  final _numberFormat = NumberFormat.decimalPattern('en_US');

  void _openAnalytics({
    required String title,
    required String searchHint,
    required String listType,
    required String requestType,
    required bool showAdd,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessActivityPage(
          title: title,
          searchHint: searchHint,
          listType: listType,
          requestType: requestType,
          showAdd: showAdd,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncUser = ref.watch(userProvider);
    return asyncUser.when(
      data: (user) => _buildDrawer(user),
      loading: () => const ColoredBox(
        color: kWhite,
        child: Center(child: CircularProgressIndicator(color: kPrimaryColor)),
      ),
      error: (_, __) => _buildDrawer(UserModel()),
    );
  }

  Widget _buildDrawer(UserModel user) {
    return AdvancedDrawer(
      drawer: customDrawer(user: user, context: context),
      backdrop: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: kWhite),
      ),
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Scaffold(
        backgroundColor: kWhite,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 78),
          child: FloatingActionButton(
            onPressed: () {
              NavigationService().pushNamed(
                'SendAnalyticRequest',
                arguments: {'isReceived': false},
              );
            },
            backgroundColor: const Color(0xFFFF6A00),
            elevation: 6,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: kWhite, size: 30),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: kPrimaryColor,
            onRefresh: () async {
              ref.invalidate(getUserDashboardProvider);
              ref.invalidate(fetchNotificationsProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 6),
                  ref.watch(getUserDashboardProvider()).when(
                        data: (dashboard) => _buildOverview(dashboard),
                        loading: _buildOverviewShimmer,
                        error: (_, __) => _buildOverview(
                          UserDashboard(
                            businessGiven: 0,
                            businessReceived: 0,
                            referralGiven: 0,
                            referralReceived: 0,
                            oneToOneCount: 0,
                          ),
                        ),
                      ),
                  const SizedBox(height: 28),
                  _buildLink(
                    icon: 'assets/pngs/dashboard_business_received.png',
                    title: 'Business Received',
                    onTap: () => _openAnalytics(
                      title: 'Business Received',
                      searchHint: 'Search business, referrals...',
                      listType: 'received',
                      requestType: 'Business',
                      showAdd: false,
                    ),
                  ),
                  _buildLink(
                    icon: 'assets/pngs/dashboard_business_given_blue.png',
                    title: 'Business Given',
                    onTap: () => _openAnalytics(
                      title: 'Business Given',
                      searchHint: 'Search, referrals...',
                      listType: 'sent',
                      requestType: 'Business',
                      showAdd: true,
                    ),
                  ),
                  _buildLink(
                    icon: 'assets/pngs/dashboard_referral_received.png',
                    title: 'Reference Received',
                    onTap: () => _openAnalytics(
                      title: 'Reference Received',
                      searchHint: 'Search, referrals...',
                      listType: 'received',
                      requestType: 'Referral',
                      showAdd: false,
                    ),
                  ),
                  _buildLink(
                    icon: 'assets/pngs/dashboard_referral_given.png',
                    title: 'Reference Given',
                    onTap: () => _openAnalytics(
                      title: 'Reference Given',
                      searchHint: 'Search, referrals...',
                      listType: 'sent',
                      requestType: 'Referral',
                      showAdd: true,
                    ),
                  ),
                  SizedBox(
                    height: 24 + 64 + MediaQuery.paddingOf(context).bottom,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 68,
      color: kWhite,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/pngs/hef_logo_square.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Spacer(),
          Consumer(
            builder: (context, ref, child) {
              final asyncNotifications = ref.watch(fetchNotificationsProvider);
              return asyncNotifications.when(
                data: (notifications) {
                  final visibleNotifications = notifications.where((notification) {
                    final userNotification = notification.users?.firstWhere(
                      (user) => user.userId == id,
                      orElse: () => UserNotification(
                        userId: '',
                        read: false,
                        cleared: false,
                      ),
                    );
                    return !(userNotification?.cleared ?? false);
                  }).toList();

                  final hasUnread = visibleNotifications.any((notification) {
                    final userNotification = notification.users?.firstWhere(
                      (user) => user.userId == id,
                      orElse: () => UserNotification(
                        userId: '',
                        read: false,
                        cleared: false,
                      ),
                    );
                    return !(userNotification?.read ?? false);
                  });

                  return _notificationButton(hasUnread);
                },
                loading: () => _notificationButton(false),
                error: (_, __) => _notificationButton(false),
              );
            },
          ),
          InkWell(
            onTap: () => _advancedDrawerController.showDrawer(),
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE9EAEC)),
              ),
              child: const Icon(
                Icons.menu_rounded,
                color: kBlack,
                size: 23,
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }

  Widget _notificationButton(bool hasUnread) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE9EAEC)),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.notifications_none_outlined,
              size: 21,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationPage(),
                ),
              );
            },
          ),
          if (hasUnread)
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverview(UserDashboard dashboard) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 18, 14, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF3EB),
              Color(0xFFFFF7F2),
              Color(0xFFFFFBF8),
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Business Overview',
                        style: TextStyle(
                          color: Color(0xFF1B1521),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Overall business and referral summary',
                        style: TextStyle(
                          color: Color(0xFF9999A6),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Image.asset(
                  'assets/pngs/business_overview.png',
                  width: 58,
                  height: 58,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFE7DFD8),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStat(
                  asset: 'assets/pngs/dashboard_business_received.png',
                  value: _numberFormat.format(dashboard.businessReceived),
                  label: 'Business\nReceived',
                  valueColor: const Color(0xFFF26500),
                ),
                _statDivider(),
                _buildStat(
                  asset: 'assets/pngs/dashboard_business_given_blue.png',
                  value: _numberFormat.format(dashboard.businessGiven),
                  label: 'Business\nGiven',
                  valueColor: const Color(0xFF1F7ED0),
                ),
                _statDivider(),
                _buildStat(
                  asset: 'assets/pngs/dashboard_referral_received.png',
                  value: _numberFormat.format(dashboard.referralReceived),
                  label: 'Referrals\nReceived',
                  valueColor: const Color(0xFF22A34A),
                ),
                _statDivider(),
                _buildStat(
                  asset: 'assets/pngs/dashboard_referral_given.png',
                  value: _numberFormat.format(dashboard.referralGiven),
                  label: 'Referrals\nGiven',
                  valueColor: const Color(0xFF9B3CC4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 86,
      margin: const EdgeInsets.only(top: 4),
      color: const Color(0xFFE6E0DB),
    );
  }

  Widget _buildStat({
    required String asset,
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Image.asset(asset, width: 32, height: 32, fit: BoxFit.contain),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: valueColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF9B9C9E),
              fontSize: 11,
              fontWeight: FontWeight.w400,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLink({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Material(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            height: 62,
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Image.asset(icon, width: 36, height: 36, fit: BoxFit.contain),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1C1C1C),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFB0B0B0),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFF3E6DC),
        highlightColor: const Color(0xFFFFFBF8),
        child: Container(
          height: 196,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3EB),
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }
}
