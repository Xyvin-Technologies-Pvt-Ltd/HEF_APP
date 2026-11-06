import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/chapter_api/chapter_details.dart';
import 'package:hef/src/data/api_routes/events_api/events_api.dart';
import 'package:hef/src/data/api_routes/levels_api/levels_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/models/chapter_directory_model.dart';
import 'package:hef/src/data/models/events_model.dart';
import 'package:hef/src/data/models/level_models/chapter_model.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/services/launch_url.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ChapterDetailPage extends ConsumerStatefulWidget {
  final ChapterDirectoryItem chapter;

  const ChapterDetailPage({super.key, required this.chapter});

  @override
  ConsumerState<ChapterDetailPage> createState() => _ChapterDetailPageState();
}

class _ChapterDetailPageState extends ConsumerState<ChapterDetailPage> {
  final TextEditingController _memberSearchController = TextEditingController();
  final NavigationService _navigationService = NavigationService();
  int _tab = 0;
  String _memberQuery = '';
  String? _businessFilter;
  final Set<String> _expandedAdmins = <String>{};

  @override
  void dispose() {
    _memberSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(fetchChapterDetailsProvider(widget.chapter.id));
    final members = ref.watch(
      fetchChapterMemberDataProvider(widget.chapter.id, 'user'),
    );
    final memberCount = members.maybeWhen(
      data: (items) => items.length,
      orElse: () => widget.chapter.memberCount,
    );

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111111), size: 22),
        ),
        title: const Text(
          'Chapter Details',
          style: TextStyle(
            fontFamily: kFamilyName,
            color: Color(0xFF111111),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF111111)),
            onSelected: (value) {
              if (value == 'share') {
                final location = widget.chapter.location;
                Share.share(
                  location.isEmpty
                      ? widget.chapter.name
                      : '${widget.chapter.name}\n$location',
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'share',
                child: Text(
                  'Share',
                  style: TextStyle(fontFamily: kFamilyName),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _header(details, memberCount),
          _tabBar(),
          Expanded(child: _tabBody(details, members, memberCount)),
        ],
      ),
    );
  }

  Widget _header(AsyncValue<ChapterDetailsModel> details, int memberCount) {
    final launchDate = details.maybeWhen(
      data: (chapter) => _formatLaunch(chapter.createdAt),
      orElse: () => widget.chapter.createdAt == null
          ? '—'
          : _formatLaunch(widget.chapter.createdAt!),
    );
    final location = widget.chapter.location.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFFFFDFB),
              Color(0xFFFFF4EC),
              Color(0xFFFFEDE1),
            ],
            stops: [0.15, 0.62, 1],
          ),
          border: Border.all(color: const Color(0xFFF6E6DA)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _SquareImage(imageUrl: widget.chapter.image, size: 56, radius: 12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.chapter.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: kFamilyName,
                          color: Color(0xFF111111),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: kFamilyName,
                            color: Color(0xFF9AA3AF),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF0F0F2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _statColumn(
                      icon: Icons.calendar_today_outlined,
                      label: 'Launch date',
                      value: launchDate,
                      valueColor: kPrimaryColor,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: const Color(0xFFE8E8EA),
                  ),
                  Expanded(
                    child: _statColumn(
                      icon: Icons.people_alt_outlined,
                      label: 'Members',
                      value: '$memberCount',
                      valueColor: const Color(0xFF111111),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statColumn({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        const SizedBox(width: 8),
        Icon(icon, size: 22, color: const Color(0xFFB0B6C0)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: kFamilyName,
                  color: Color(0xFF9AA3AF),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: kFamilyName,
                  color: valueColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabBar() {
    const labels = ['Committee', 'Members', 'Meeting'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: List.generate(labels.length, (index) {
            final selected = _tab == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _tab = index),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? kPrimaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      fontFamily: kFamilyName,
                      color: selected ? kWhite : const Color(0xFF8B93A1),
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _tabBody(
    AsyncValue<ChapterDetailsModel> details,
    AsyncValue<List<UserModel>> members,
    int memberCount,
  ) {
    switch (_tab) {
      case 1:
        return _membersTab(members);
      case 2:
        return _meetingsTab();
      default:
        return _committeeTab(details, members);
    }
  }

  Widget _committeeTab(
    AsyncValue<ChapterDetailsModel> details,
    AsyncValue<List<UserModel>> members,
  ) {
    return details.when(
      data: (chapter) {
        final admins = chapter.admins;
        final people = members.valueOrNull ?? const <UserModel>[];
        final label = admins.length == 1
            ? '1 coordinator'
            : '${admins.length} coordinators';
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Management Committee',
                    style: TextStyle(
                      fontFamily: kFamilyName,
                      color: Color(0xFF111111),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: kFamilyName,
                    color: Color(0xFF9AA3AF),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (admins.isEmpty)
              const _EmptyNote(message: 'No coordinators listed yet')
            else
              ...admins.map((admin) {
                final person = _matchMember(people, admin.user.id);
                final expanded = _expandedAdmins.contains(admin.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CoordinatorCard(
                    admin: admin,
                    person: person,
                    fallbackLocation: widget.chapter.location,
                    expanded: expanded,
                    onToggle: () {
                      setState(() {
                        if (expanded) {
                          _expandedAdmins.remove(admin.id);
                        } else {
                          _expandedAdmins.add(admin.id);
                        }
                      });
                    },
                    onViewProfile: () => _openProfile(
                      user: person,
                      userId: admin.user.id,
                    ),
                    onCall: () => _call(admin.user.phone),
                    onShare: () {
                      final role = _titleCase(admin.role);
                      final lines = [
                        admin.user.name,
                        if (role.isNotEmpty) role,
                        if (admin.user.phone.trim().isNotEmpty) admin.user.phone,
                      ];
                      Share.share(lines.join('\n'));
                    },
                  ),
                );
              }),
          ],
        );
      },
      loading: () => const Center(child: LoadingAnimation()),
      error: (error, stackTrace) => const _EmptyNote(
        message: 'Unable to load the committee',
      ),
    );
  }

  Widget _membersTab(AsyncValue<List<UserModel>> members) {
    return members.when(
      data: (items) {
        final businesses = items
            .map(_companyName)
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
        final query = _memberQuery.trim().toLowerCase();
        final visible = items.where((member) {
          final company = _companyName(member);
          final matchesQuery = query.isEmpty ||
              (member.name ?? '').toLowerCase().contains(query) ||
              company.toLowerCase().contains(query) ||
              (member.address ?? '').toLowerCase().contains(query);
          final matchesBusiness =
              _businessFilter == null || company == _businessFilter;
          return matchesQuery && matchesBusiness;
        }).toList();
        final countLabel =
            items.length == 1 ? '1 member' : '${items.length} members';

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _memberSearchController,
                      onChanged: (value) => setState(() => _memberQuery = value),
                      style: const TextStyle(
                        fontFamily: kFamilyName,
                        fontSize: 14,
                        color: Color(0xFF111111),
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Search members by name or business...',
                        hintStyle: const TextStyle(
                          fontFamily: kFamilyName,
                          color: Color(0xFF9AA1AB),
                          fontSize: 13.5,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFFB0B6BE),
                          size: 22,
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 44, minHeight: 48),
                        filled: true,
                        fillColor: kWhite,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        constraints:
                            const BoxConstraints(minHeight: 48, maxHeight: 48),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE6E8EC)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE6E8EC)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _memberFilterButton(businesses),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Chapter Members',
                      style: TextStyle(
                        fontFamily: kFamilyName,
                        color: Color(0xFF111111),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    countLabel,
                    style: const TextStyle(
                      fontFamily: kFamilyName,
                      color: Color(0xFF9AA3AF),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: visible.isEmpty
                  ? const _EmptyNote(message: 'No members found')
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: visible.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final member = visible[index];
                        return _MemberCard(
                          member: member,
                          company: _companyName(member),
                          location: _memberLocation(member),
                          onCall: () => _call(member.phone ?? ''),
                          onOpen: () => _openProfile(
                            user: member,
                            userId: member.uid ?? '',
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: LoadingAnimation()),
      error: (error, stackTrace) =>
          const _EmptyNote(message: 'Unable to load members'),
    );
  }

  Widget _memberFilterButton(List<String> businesses) {
    final active = _businessFilter != null;
    return SizedBox(
      width: 48,
      height: 48,
      child: Material(
        color: kWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: active ? kPrimaryColor : const Color(0xFFE6E8EC),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openBusinessFilter(businesses),
          child: Icon(
            Icons.tune,
            color: active ? kPrimaryColor : const Color(0xFF6B7280),
            size: 22,
          ),
        ),
      ),
    );
  }

  Future<void> _openBusinessFilter(List<String> businesses) async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: kWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Filter by business',
                          style: TextStyle(
                            fontFamily: kFamilyName,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, ''),
                        child: const Text(
                          'Clear',
                          style: TextStyle(
                            fontFamily: kFamilyName,
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      if (businesses.isEmpty)
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Text(
                            'No businesses to filter',
                            style: TextStyle(
                              fontFamily: kFamilyName,
                              color: Color(0xFF8B93A0),
                            ),
                          ),
                        ),
                      ...businesses.map((business) {
                        return ListTile(
                          title: Text(
                            business,
                            style: const TextStyle(fontFamily: kFamilyName),
                          ),
                          trailing: _businessFilter == business
                              ? const Icon(Icons.check, color: kPrimaryColor)
                              : null,
                          onTap: () => Navigator.pop(context, business),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || selected == null) return;
    setState(() => _businessFilter = selected.isEmpty ? null : selected);
  }

  Widget _meetingsTab() {
    final events = ref.watch(fetchEventsProvider);
    return events.when(
      data: (items) {
        final upcoming = _upcomingMeetings(items);
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: [
            const Text(
              'Upcoming Meeting',
              style: TextStyle(
                fontFamily: kFamilyName,
                color: Color(0xFF111111),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (upcoming.isEmpty)
              const _EmptyNote(message: 'No upcoming meetings')
            else
              ...upcoming.map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _MeetingCard(
                    event: event,
                    fallbackLocation: widget.chapter.location,
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: LoadingAnimation()),
      error: (error, stackTrace) =>
          const _EmptyNote(message: 'Unable to load meetings'),
    );
  }

  List<Event> _upcomingMeetings(List<Event> events) {
    bool isUpcoming(Event event) {
      final raw = event.eventDate ?? event.startDate ?? event.startTime;
      if (raw == null) return false;
      final local = raw.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return !day.isBefore(today);
    }

    bool matchesChapter(Event event) {
      final chapters = event.chapters;
      if (chapters == null || chapters.isEmpty) return false;
      final id = widget.chapter.id;
      final name = widget.chapter.name.toLowerCase();
      return chapters.any(
        (chapter) => chapter == id || chapter.toLowerCase() == name,
      );
    }

    final targeted = events.where(matchesChapter).where(isUpcoming).toList();
    final source = targeted.isNotEmpty
        ? targeted
        : events.where((event) {
            final chapters = event.chapters;
            return (chapters == null || chapters.isEmpty) && isUpcoming(event);
          }).toList();
    source.sort((a, b) {
      final ad = a.eventDate ?? a.startDate ?? a.startTime ?? DateTime(2100);
      final bd = b.eventDate ?? b.startDate ?? b.startTime ?? DateTime(2100);
      return ad.compareTo(bd);
    });
    return source;
  }

  UserModel? _matchMember(List<UserModel> members, String userId) {
    for (final member in members) {
      if (member.uid == userId) return member;
    }
    return null;
  }

  String _companyName(UserModel member) {
    final company = member.company;
    if (company != null && company.isNotEmpty) {
      final name = company.first.name?.trim() ?? '';
      if (name.isNotEmpty) return name;
    }
    final category = member.businessCategory?.trim() ?? '';
    if (category.isNotEmpty) return category;
    return member.designation?.trim() ?? '';
  }

  String _memberLocation(UserModel member) {
    final address = member.address?.trim() ?? '';
    if (address.isNotEmpty) return address;
    return widget.chapter.location;
  }

  String _formatLaunch(DateTime date) {
    if (date.year < 2000) return 'Not specified';
    return DateFormat('dd MMM yyyy').format(date.toLocal());
  }

  String _titleCase(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) return word;
      final lower = word.toLowerCase();
      return '${lower[0].toUpperCase()}${lower.substring(1)}';
    }).join(' ');
  }

  void _openProfile({UserModel? user, required String userId}) {
    if (user != null && (user.uid ?? '').isNotEmpty) {
      _navigationService.pushNamed('ProfilePreview', arguments: user);
      return;
    }
    if (userId.isNotEmpty) {
      _navigationService.pushNamed('ProfilePreviewUsingID', arguments: userId);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile is not available')),
    );
  }

  void _call(String phone) {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number is not available')),
      );
      return;
    }
    launchPhone(trimmed);
  }
}

class _CoordinatorCard extends StatelessWidget {
  final Admin admin;
  final UserModel? person;
  final String fallbackLocation;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onViewProfile;
  final VoidCallback onCall;
  final VoidCallback onShare;

  const _CoordinatorCard({
    required this.admin,
    required this.person,
    required this.fallbackLocation,
    required this.expanded,
    required this.onToggle,
    required this.onViewProfile,
    required this.onCall,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final name = admin.user.name.trim().isEmpty ? 'Member' : admin.user.name.trim();
    final role = _roleLabel(admin.role);
    final location = _location();
    final about = _about();

    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEF1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  _PersonAvatar(imageUrl: admin.user.image, name: name),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: kFamilyName,
                            color: Color(0xFF111111),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (!expanded && role.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            role,
                            style: const TextStyle(
                              fontFamily: kFamilyName,
                              color: Color(0xFF9AA3AF),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF9AA3AE),
                  ),
                ],
              ),
            ),
            if (expanded) ...[
              if (location.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Color(0xFF9AA3AF),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: kFamilyName,
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (about.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  about,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: kFamilyName,
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
              if (role.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kPrimaryColor),
                  ),
                  child: Text(
                    role,
                    style: const TextStyle(
                      fontFamily: kFamilyName,
                      color: kPrimaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: onViewProfile,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kPrimaryColor,
                          side: const BorderSide(color: kPrimaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'View Profile',
                              style: TextStyle(
                                fontFamily: kFamilyName,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.chevron_right, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _iconButton(Icons.phone_outlined, onCall),
                  const SizedBox(width: 8),
                  _iconButton(Icons.share_outlined, onShare),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 46,
      height: 46,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimaryColor,
          side: const BorderSide(color: kPrimaryColor),
          padding: EdgeInsets.zero,
          minimumSize: const Size(46, 46),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  String _location() {
    final address = person?.address?.trim() ?? '';
    if (address.isNotEmpty) return address;
    return fallbackLocation.trim();
  }

  String _about() {
    final bio = person?.bio?.trim() ?? '';
    if (bio.isNotEmpty) return bio;
    final companies = person?.company
            ?.map((company) => company.name?.trim() ?? '')
            .where((name) => name.isNotEmpty)
            .toList() ??
        const <String>[];
    if (companies.isNotEmpty) return companies.join(', ');
    final designation = person?.designation?.trim() ?? '';
    if (designation.isNotEmpty) return designation;
    return '';
  }

  String _roleLabel(String role) {
    final trimmed = role.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) return word;
      final lower = word.toLowerCase();
      return '${lower[0].toUpperCase()}${lower.substring(1)}';
    }).join(' ');
  }
}

class _MemberCard extends StatelessWidget {
  final UserModel member;
  final String company;
  final String location;
  final VoidCallback onCall;
  final VoidCallback onOpen;

  const _MemberCard({
    required this.member,
    required this.company,
    required this.location,
    required this.onCall,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final name = (member.name ?? '').trim().isEmpty ? 'Member' : member.name!.trim();
    return Material(
      color: kWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEEEEF1)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              _PersonAvatar(imageUrl: member.image, name: name, showStatus: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: kFamilyName,
                        color: Color(0xFF111111),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (company.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        company,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: kFamilyName,
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (location.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: kFamilyName,
                          color: Color(0xFF9AA3AF),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 36,
                height: 36,
                child: OutlinedButton(
                  onPressed: onCall,
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimaryColor,
          side: const BorderSide(color: kPrimaryColor),
          padding: EdgeInsets.zero,
          minimumSize: const Size(36, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const CircleBorder(),
        ),
                  child: const Icon(Icons.phone_outlined, size: 18),
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFC5CAD1), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final Event event;
  final String fallbackLocation;

  const _MeetingCard({
    required this.event,
    required this.fallbackLocation,
  });

  @override
  Widget build(BuildContext context) {
    final when = event.eventDate ?? event.startDate ?? event.startTime;
    final local = when?.toLocal();
    final dateText =
        local == null ? 'Not specified' : DateFormat('MMMM d, yyyy').format(local);
    final venue = (event.venue ?? '').trim();
    final venueTitle = _venueTitle(venue, event.eventName);
    final venueAddress = _venueAddress(venue);
    final info = (event.description ?? '').trim();
    final infoText = info.isNotEmpty
        ? info
        : 'Check with the chapter coordinator for updates.';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEF1)),
      ),
      child: Column(
        children: [
          _meetingRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: dateText,
            trailing: _daysBadge(local),
          ),
          const SizedBox(height: 14),
          _meetingRow(
            icon: Icons.access_time,
            label: 'Time',
            value: _timeRange(),
          ),
          const SizedBox(height: 14),
          _meetingRow(
            icon: Icons.location_on_outlined,
            label: 'Meeting venue',
            value: venueTitle,
            detail: venueAddress,
          ),
          const SizedBox(height: 14),
          _meetingRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Meeting fee',
            value: 'Not specified',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _directions(venueTitle),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: kWhite,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.near_me_outlined, size: 18),
              label: const Text(
                'Get Directions',
                style: TextStyle(
                  fontFamily: kFamilyName,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _addToCalendar(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: kPrimaryColor,
                side: const BorderSide(color: kPrimaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: const Text(
                'Add to Calendar',
                style: TextStyle(
                  fontFamily: kFamilyName,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFBFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF0F1F3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1E8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: kPrimaryColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Meeting Information',
                        style: TextStyle(
                          fontFamily: kFamilyName,
                          color: Color(0xFF111111),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        infoText,
                        style: const TextStyle(
                          fontFamily: kFamilyName,
                          color: Color(0xFF8B93A0),
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _meetingRow({
    required IconData icon,
    required String label,
    required String value,
    String? detail,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFF4F5F7),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF9AA3AF)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: kFamilyName,
                  color: Color(0xFF9AA3AF),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: kFamilyName,
                  color: Color(0xFF111111),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (detail != null && detail.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(
                    fontFamily: kFamilyName,
                    color: Color(0xFF8B93A0),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _daysBadge(DateTime? date) {
    if (date == null) return const SizedBox.shrink();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = day.difference(today).inDays;
    final label = diff <= 0
        ? 'Today'
        : diff == 1
            ? 'In 1 day'
            : 'In $diff days';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1E8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, size: 13, color: kPrimaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: kFamilyName,
              color: kPrimaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _timeRange() {
    final start = event.startTime ?? event.eventDate ?? event.startDate;
    if (start == null) return 'Not specified';
    final startText = DateFormat('h:mm a').format(start.toLocal());
    final end = event.endTime ?? event.endDate;
    if (end == null) return startText;
    final endText = DateFormat('h:mm a').format(end.toLocal());
    return '$startText - $endText';
  }

  String _venueTitle(String venue, String? eventName) {
    if (venue.isEmpty) {
      final name = eventName?.trim() ?? '';
      return name.isEmpty ? 'Not specified' : name;
    }
    if (venue.contains(',')) return venue.split(',').first.trim();
    return venue;
  }

  String? _venueAddress(String venue) {
    if (!venue.contains(',')) return null;
    final rest = venue.split(',').skip(1).join(',').trim();
    return rest.isEmpty ? null : rest;
  }

  Future<void> _directions(String venueTitle) async {
    final query = (event.venue ?? '').trim().isNotEmpty
        ? event.venue!.trim()
        : (fallbackLocation.trim().isNotEmpty ? fallbackLocation : venueTitle);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _addToCalendar(BuildContext context) async {
    final start = event.startTime ?? event.eventDate ?? event.startDate;
    if (start == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meeting date is not available')),
      );
      return;
    }
    final end = event.endTime ?? event.endDate ?? start.add(const Duration(hours: 1));
    String stamp(DateTime value) =>
        DateFormat("yyyyMMdd'T'HHmmss'Z'").format(value.toUtc());
    final title = (event.eventName ?? '').trim().isEmpty
        ? 'Chapter Meeting'
        : event.eventName!.trim();
    final uri = Uri.parse(
      'https://calendar.google.com/calendar/render?action=TEMPLATE'
      '&text=${Uri.encodeComponent(title)}'
      '&dates=${stamp(start)}/${stamp(end)}'
      '&location=${Uri.encodeComponent(event.venue ?? fallbackLocation)}'
      '&details=${Uri.encodeComponent(event.description ?? '')}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _PersonAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final bool showStatus;

  const _PersonAvatar({
    required this.imageUrl,
    required this.name,
    this.showStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    final fallback = Container(
      color: const Color(0xFFFFEEE2),
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: const TextStyle(
          fontFamily: kFamilyName,
          color: kPrimaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    final hasNetwork = imageUrl != null &&
        (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'));
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 52,
              height: 52,
              child: hasNetwork
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => fallback,
                    )
                  : fallback,
            ),
          ),
          if (showStatus)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.all(color: kWhite, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SquareImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double radius;

  const _SquareImage({
    required this.imageUrl,
    required this.size,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Image.asset(
      'assets/pngs/hef_logo_square.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
    final hasNetwork = imageUrl != null &&
        (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'));
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: hasNetwork
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => fallback,
              )
            : fallback,
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  final String message;

  const _EmptyNote({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: kFamilyName,
            color: Color(0xFF8B93A0),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
