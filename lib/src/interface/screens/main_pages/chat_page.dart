import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/notification_api/notification_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/notification_model.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:hef/src/interface/components/Drawer/drawer.dart';
import 'package:hef/src/interface/components/common/community_chrome.dart';
import 'package:hef/src/interface/screens/main_pages/bussiness_products/business_view.dart';
import 'package:hef/src/interface/screens/main_pages/bussiness_products/product_view.dart';
import 'package:hef/src/interface/screens/main_pages/chat/chat_dash.dart';
import 'package:hef/src/interface/screens/main_pages/chat/members.dart';
import 'package:hef/src/interface/screens/main_pages/notification_page.dart';

class PeoplePage extends ConsumerStatefulWidget {
  const PeoplePage({super.key});

  @override
  ConsumerState<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends ConsumerState<PeoplePage> {
  final _advancedDrawerController = AdvancedDrawerController();
  final List<Widget?> _pages = List<Widget?>.filled(4, null);
  int _index = 0;

  static const _labels = ['Feed', 'Members', 'Chat', 'Ecommerce'];

  @override
  void initState() {
    super.initState();
    _pages[0] = const BusinessView();
  }

  @override
  void dispose() {
    _advancedDrawerController.dispose();
    super.dispose();
  }

  void _select(int index) {
    setState(() {
      _index = index;
      _pages[index] ??= _createPage(index);
    });
  }

  Widget _createPage(int index) {
    switch (index) {
      case 1:
        return const MembersPage();
      case 2:
        return ChatDash(onStartChat: () => _select(1));
      case 3:
        return const ProductView();
      default:
        return const BusinessView();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncUser = ref.watch(userProvider);
    return asyncUser.when(
      data: _buildShell,
      loading: () => _buildShell(UserModel()),
      error: (_, __) => _buildShell(UserModel()),
    );
  }

  Widget _buildShell(UserModel user) {
    return AdvancedDrawer(
      drawer: customDrawer(user: user, context: context),
      backdrop: const ColoredBox(color: kWhite),
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
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              _buildTabs(),
              Expanded(
                child: IndexedStack(
                  index: _index,
                  children: List.generate(
                    4,
                    (index) => _pages[index] ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 64,
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
                  final visible = notifications.where((notification) {
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
                  final hasUnread = visible.any((notification) {
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
                  return _bell(hasUnread: hasUnread);
                },
                loading: () => _bell(hasUnread: false),
                error: (_, __) => _bell(hasUnread: false),
              );
            },
          ),
          InkWell(
            onTap: _advancedDrawerController.showDrawer,
            customBorder: const CircleBorder(),
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE9EAEC)),
              ),
              child: const Icon(Icons.menu_rounded, color: kBlack, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bell({required bool hasUnread}) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE9EAEC)),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.notifications_none_outlined, size: 22),
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
            const Positioned(
              right: 11,
              top: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: kCommunityOrange,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(width: 8, height: 8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
      child: Row(
        children: List.generate(_labels.length, (index) {
          final selected = index == _index;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _select(index),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? kCommunityOrangeSoft : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _labels[index],
                    maxLines: 1,
                    style: TextStyle(
                      color: selected ? kCommunityOrange : kCommunityMuted,
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
