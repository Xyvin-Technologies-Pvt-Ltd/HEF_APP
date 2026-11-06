import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/notification_api/notification_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/chapter_directory_model.dart';
import 'package:hef/src/data/models/notification_model.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/interface/components/Drawer/drawer.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/levels/chapter_detail_page.dart';
import 'package:hef/src/interface/screens/main_pages/notification_page.dart';
import 'package:share_plus/share_plus.dart';

const Color _ink = Color(0xFF1C1F26);
const Color _muted = Color(0xFF8B939E);
const Color _line = Color(0xFFE8EAED);
const Color _orange = Color(0xFFFF6D00);
const Color _page = Color(0xFFF6F7F9);

class ProfilePage extends ConsumerStatefulWidget {
  final UserModel user;
  const ProfilePage({super.key, required this.user});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _drawerController = AdvancedDrawerController();
  final _navigation = NavigationService();

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liveUser = ref.watch(userProvider).value ?? widget.user;
    return AdvancedDrawer(
      drawer: customDrawer(user: liveUser, context: context),
      backdrop: const ColoredBox(color: kWhite),
      controller: _drawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Scaffold(
        backgroundColor: _page,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _header(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
                  children: [
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontFamily: kFamilyName,
                        color: _ink,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _identityCard(liveUser),
                    const SizedBox(height: 14),
                    _actionRow(liveUser),
                    const SizedBox(height: 26),
                    const Text(
                      'Digital Membership Card',
                      style: TextStyle(
                        fontFamily: kFamilyName,
                        color: _ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _membershipPromo(liveUser),
                    const SizedBox(height: 26),
                    const Text(
                      'Profile & Membership',
                      style: TextStyle(
                        fontFamily: kFamilyName,
                        color: _ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _menuCard(liveUser),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
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
                data: (notifications) => _bell(hasUnread: _hasUnread(notifications)),
                loading: () => _bell(hasUnread: false),
                error: (_, __) => _bell(hasUnread: false),
              );
            },
          ),
          InkWell(
            onTap: _drawerController.showDrawer,
            customBorder: const CircleBorder(),
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE9EAEC)),
              ),
              child: const Icon(Icons.menu_rounded, color: _ink, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasUnread(List<NotificationModel> notifications) {
    return notifications.any((notification) {
      final userNotification = notification.users?.firstWhere(
        (user) => user.userId == id,
        orElse: () => UserNotification(userId: '', read: false, cleared: false),
      );
      final cleared = userNotification?.cleared ?? false;
      final read = userNotification?.read ?? false;
      return !cleared && !read;
    });
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
            icon: const Icon(Icons.notifications_none_outlined, size: 22, color: _ink),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationPage()),
              );
            },
          ),
          if (hasUnread)
            const Positioned(
              right: 11,
              top: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(color: _orange, shape: BoxShape.circle),
                child: SizedBox(width: 8, height: 8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _identityCard(UserModel user) {
    final company = _companyLine(user);
    final chapter = _chapterName(user);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _avatar(user),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      _text(user.name).isEmpty ? 'Member' : user.name!.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: kFamilyName,
                        color: _ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.verified, color: _orange, size: 18),
                ],
              ),
              if (company.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  company,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: kFamilyName,
                    color: _muted,
                    fontSize: 13,
                    height: 1.25,
                  ),
                ),
              ],
              if (chapter.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  chapter,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: kFamilyName,
                    color: Color(0xFF5E6672),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: const Color(0xFFFFF1E8),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _navigation.pushNamed('EditUser'),
            child: const SizedBox(
              width: 46,
              height: 46,
              child: Icon(Icons.edit_outlined, color: _orange, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatar(UserModel user) {
    final image = user.image;
    final hasImage = image != null && image.trim().isNotEmpty;
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF1F2F4),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.person, color: _muted, size: 36),
            )
          : const Icon(Icons.person, color: _muted, size: 36),
    );
  }

  Widget _actionRow(UserModel user) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                final uid = user.uid;
                if (uid == null || uid.isEmpty) return;
                _navigation.pushNamed('ProfilePreviewUsingID', arguments: uid);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _ink,
                backgroundColor: Colors.white,
                side: const BorderSide(color: _line),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.visibility_outlined, size: 18, color: Color(0xFF4B5563)),
              label: const Text(
                'View Profile',
                style: TextStyle(
                  fontFamily: kFamilyName,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _shareProfile(user),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.share_outlined, size: 18),
              label: const Text(
                'Share Profile',
                style: TextStyle(
                  fontFamily: kFamilyName,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _membershipPromo(UserModel user) {
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _navigation.pushNamed('Card', arguments: user),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 16, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF0F1F3)),
            boxShadow: const [
              BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              const _CardArt(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your official HEF membership identity for events, networking and chapter activities.',
                      style: TextStyle(
                        fontFamily: kFamilyName,
                        color: Color(0xFF4B5563),
                        fontSize: 13.5,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Text(
                          'View Member Card',
                          style: TextStyle(
                            fontFamily: kFamilyName,
                            color: _ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, color: _orange, size: 18),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuCard(UserModel user) {
    final company = _businessSubtitle(user);
    final chapter = _chapterName(user);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0F1F3)),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          _menuRow(
            icon: Icons.work_outline,
            tint: const Color(0xFFFFF1E8),
            iconColor: _orange,
            title: 'Business Information',
            subtitle: company.isEmpty ? 'Company and business details' : company,
            onTap: () => _navigation.pushNamed('MyBusinesses'),
          ),
          const Divider(height: 1, color: Color(0xFFF2F3F5)),
          _menuRow(
            icon: Icons.menu_book_outlined,
            tint: const Color(0xFFEEF0FF),
            iconColor: const Color(0xFF5B6CFF),
            title: 'My Chapter',
            subtitle: chapter.isEmpty ? 'Chapter details' : chapter,
            onTap: () => _openChapter(user),
          ),
          const Divider(height: 1, color: Color(0xFFF2F3F5)),
          _menuRow(
            icon: Icons.badge_outlined,
            tint: const Color(0xFFE8F8EF),
            iconColor: const Color(0xFF22A06B),
            title: 'My Membership',
            subtitle: 'Membership type, validity and details',
            onTap: () => _navigation.pushNamed('MySubscriptionPage'),
          ),
        ],
      ),
    );
  }

  Widget _menuRow({
    required IconData icon,
    required Color tint,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: kFamilyName,
                      color: _ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: kFamilyName,
                      color: _muted,
                      fontSize: 12.5,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFC5CAD3), size: 22),
          ],
        ),
      ),
    );
  }

  void _openChapter(UserModel user) {
    final chapterId = (user.chapter?.id ?? '').trim().isNotEmpty
        ? user.chapter!.id!.trim()
        : (user.levelId ?? '').trim();
    if (chapterId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chapter is not available yet')),
      );
      return;
    }
    final name = _chapterName(user);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChapterDetailPage(
          chapter: ChapterDirectoryItem(
            id: chapterId,
            name: name.isEmpty ? 'Chapter' : name,
            location: user.chapter?.district?.name ?? '',
            districtName: user.chapter?.district?.name ?? '',
            memberCount: 0,
          ),
        ),
      ),
    );
  }

  Future<void> _shareProfile(UserModel user) async {
    final name = _text(user.name);
    final chapter = _chapterName(user);
    final link = (user.uid ?? '').isEmpty
        ? ''
        : 'https://admin.hefconnect.in/user/${user.uid}';
    final lines = [
      if (name.isNotEmpty) name,
      if (chapter.isNotEmpty) chapter,
      if (link.isNotEmpty) link,
    ];
    if (lines.isEmpty) return;
    await Share.share(lines.join('\n'));
  }

  Company? _primaryCompany(UserModel user) {
    for (final item in user.company ?? const <Company>[]) {
      if (_text(item.name).isNotEmpty || _text(item.designation).isNotEmpty) {
        return item;
      }
    }
    return null;
  }

  String _companyLine(UserModel user) {
    final company = _primaryCompany(user);
    final name = _text(company?.name);
    final designation = _text(company?.designation);
    if (name.isEmpty && designation.isEmpty) {
      return _text(user.designation);
    }
    if (name.isEmpty) return designation;
    if (designation.isEmpty) return name;
    return '$name  •  $designation';
  }

  String _businessSubtitle(UserModel user) {
    final company = _primaryCompany(user);
    final name = _text(company?.name);
    final category = _text(user.businessCategory);
    if (name.isEmpty) return category;
    if (category.isEmpty) return name;
    return '$name  •  $category';
  }

  String _chapterName(UserModel user) {
    final chapter = _text(user.chapter?.name);
    if (chapter.isNotEmpty) return chapter;
    return _text(user.levelName);
  }

  String _text(String? value) => (value ?? '').trim();
}

class _CardArt extends StatelessWidget {
  const _CardArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86,
      height: 72,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 8,
            top: 6,
            child: Transform.rotate(
              angle: -0.12,
              child: Container(
                width: 58,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7DEFF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD5C8F5)),
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 14,
            child: Container(
              width: 62,
              height: 44,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F4FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD9CEF8)),
                boxShadow: const [
                  BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Image.asset(
                          'assets/pngs/hef_logo_square.png',
                          width: 14,
                          height: 14,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'HEF',
                        style: TextStyle(
                          fontFamily: kFamilyName,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: _orange,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(Icons.qr_code_2, size: 16, color: Colors.black.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
