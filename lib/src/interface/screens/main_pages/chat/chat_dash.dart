import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hef/src/data/api_routes/chat_api/chat_api.dart';
import 'package:hef/src/data/api_routes/group_chat_api/group_api.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/chat_model.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/interface/components/common/community_chrome.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/screens/main_pages/chat/chat_screen.dart';
import 'package:hef/src/interface/screens/main_pages/chat/groupchatscreen.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class ChatDash extends ConsumerStatefulWidget {
  final VoidCallback? onStartChat;

  const ChatDash({super.key, this.onStartChat});

  @override
  ConsumerState<ChatDash> createState() => _ChatDashState();
}

class _ChatDashState extends ConsumerState<ChatDash> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _searchQuery = '';
  bool _groups = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    final local = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    if (day == today) return DateFormat('h:mm a').format(local);
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('d MMM').format(local);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 78),
        child: SizedBox(
          width: 58,
          height: 58,
          child: FloatingActionButton(
            elevation: 4,
            backgroundColor: kCommunityOrange,
            shape: const CircleBorder(),
            onPressed: widget.onStartChat,
            child: const Icon(
              Icons.maps_ugc_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _segment(label: 'Members', groups: false)),
                const SizedBox(width: 10),
                Expanded(child: _segment(label: 'Groups', groups: true)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CommunitySearchField(
              controller: _searchController,
              focusNode: _searchFocus,
              hint: _groups
                  ? 'Search groups...'
                  : 'Search members by name, chapter, or business...',
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
              onSubmitted: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(child: _groups ? _groupList() : _memberList()),
        ],
      ),
    );
  }

  Widget _segment({required String label, required bool groups}) {
    final selected = _groups == groups;
    return GestureDetector(
      onTap: () => setState(() => _groups = groups),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: selected ? kCommunityOrange : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              groups ? Icons.groups_outlined : Icons.chat_bubble_outline,
              size: 18,
              color: selected ? Colors.white : const Color(0xFF8B939E),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF6B7280),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _memberList() {
    final asyncChats = ref.watch(fetchChatThreadProvider);
    return asyncChats.when(
      data: (chats) {
        final filtered = chats.where((chat) {
          final receiver = chat.participants?.cast<Participant?>().firstWhere(
                (p) => p?.id != id,
                orElse: () => null,
              );
          final name = receiver?.name?.toLowerCase() ?? '';
          final message = chat.lastMessage?.content?.toLowerCase() ?? '';
          return name.contains(_searchQuery) || message.contains(_searchQuery);
        }).toList();

        if (filtered.isEmpty) return _empty('No chat yet!');

        return ListView.separated(
          padding: const EdgeInsets.only(top: 4, bottom: 150),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF1F2F4),
          ),
          itemBuilder: (context, index) {
            final chat = filtered[index];
            final receiver = chat.participants?.firstWhere(
              (p) => p.id != id,
              orElse: () => Participant(),
            );
            final sender = chat.participants?.firstWhere(
              (p) => p.id == id,
              orElse: () => Participant(id: id),
            );
            final unread = sender?.id == null
                ? 0
                : (chat.unreadCount?[sender!.id] ?? 0);
            return _ConversationTile(
              name: receiver?.name ?? '',
              imageUrl: receiver?.image,
              message: chat.lastMessage?.content ?? '',
              time: _formatTime(
                chat.lastMessage?.createdAt ?? chat.updatedAt,
              ),
              unread: unread,
              userId: receiver?.id,
              active: unread > 0,
              onTap: () {
                if (receiver == null || sender == null) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => IndividualPage(
                      receiver: receiver,
                      sender: sender,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: LoadingAnimation()),
      error: (_, __) => _empty('Could not load chats'),
    );
  }

  Widget _groupList() {
    final asyncGroups = ref.watch(getGroupListProvider);
    return asyncGroups.when(
      data: (groups) {
        final filtered = groups.where((group) {
          final name = group.groupName?.toLowerCase() ?? '';
          final message = group.lastMessage?.toLowerCase() ?? '';
          return name.contains(_searchQuery) || message.contains(_searchQuery);
        }).toList();
        if (filtered.isEmpty) return _empty('No group chat yet!');
        return ListView.separated(
          padding: const EdgeInsets.only(top: 4, bottom: 150),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF1F2F4),
          ),
          itemBuilder: (context, index) {
            final group = filtered[index];
            return _ConversationTile(
              name: group.groupName ?? '',
              message: group.lastMessage ?? '',
              time: '',
              unread: group.unreadCount ?? 0,
              group: true,
              active: (group.unreadCount ?? 0) > 0,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Groupchatscreen(
                      group: Participant(
                        id: group.id,
                        name: group.groupName,
                      ),
                      sender: Participant(id: id),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: LoadingAnimation()),
      error: (_, __) => _empty('No Groups'),
    );
  }

  Widget _empty(String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/pngs/nochat.png', height: 140),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: kCommunitySub)),
      ],
    );
  }
}

class _ConversationTile extends ConsumerWidget {
  final String name;
  final String? imageUrl;
  final String message;
  final String time;
  final int unread;
  final bool active;
  final bool group;
  final String? userId;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.name,
    required this.message,
    required this.time,
    required this.unread,
    required this.onTap,
    this.imageUrl,
    this.userId,
    this.active = false,
    this.group = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = (!group && userId != null && userId!.isNotEmpty)
        ? ref.watch(fetchUserDetailsProvider(userId!)).asData?.value
        : null;
    final meta = _meta(user);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _avatar(),
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
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: kCommunityText,
                      height: 1.2,
                    ),
                  ),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: kCommunitySub,
                        height: 1.25,
                      ),
                    ),
                  ],
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (time.isNotEmpty)
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: kCommunityMuted,
                    ),
                  ),
                if (unread > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: kCommunityOrange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _meta(UserModel? user) {
    if (group) return '';
    final company = (user?.company?.isNotEmpty ?? false)
        ? user!.company!.first.name?.trim()
        : null;
    final chapter = user?.chapter?.name?.trim();
    final parts = [company, chapter]
        .whereType<String>()
        .where((part) => part.isNotEmpty)
        .toList();
    return parts.join(' • ');
  }

  Widget _avatar() {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        children: [
          ClipOval(
            child: SizedBox(
              width: 48,
              height: 48,
              child: group
                  ? const ColoredBox(
                      color: Color(0xFFFFE8D6),
                      child: Icon(Icons.groups, color: kCommunityOrange),
                    )
                  : Image.network(
                      imageUrl ?? '',
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: const ColoredBox(color: Color(0xFFE5E7EB)),
                        );
                      },
                      errorBuilder: (_, __, ___) => SvgPicture.asset(
                        'assets/svg/icons/dummy_person_small.svg',
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: active ? const Color(0xFF22C55E) : const Color(0xFFD1D5DB),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
