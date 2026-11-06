import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/chapter_api/chapter_details.dart';
import 'package:hef/src/data/api_routes/levels_api/levels_api.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

const Color _ink = Color(0xFF1C1F26);
const Color _muted = Color(0xFF8B939E);
const Color _orange = Color(0xFFFF6D00);

class KnowYourTeamPage extends ConsumerStatefulWidget {
  final String chapterId;

  const KnowYourTeamPage({super.key, required this.chapterId});

  @override
  ConsumerState<KnowYourTeamPage> createState() => _KnowYourTeamPageState();
}

class _KnowYourTeamPageState extends ConsumerState<KnowYourTeamPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(
      fetchChapterMemberDataProvider(widget.chapterId, 'user'),
    );
    final details = ref.watch(fetchChapterDetailsProvider(widget.chapterId));
    final roles = <String, String>{};
    details.whenData((chapter) {
      for (final admin in chapter.admins) {
        final id = admin.user.id.trim();
        if (id.isNotEmpty) roles[id] = admin.role;
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: _ink, size: 22),
        ),
        title: const Text(
          'Know Your Team',
          style: TextStyle(
            fontFamily: kFamilyName,
            color: _ink,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F1F3)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
                style: const TextStyle(
                  fontFamily: kFamilyName,
                  fontSize: 14,
                  color: _ink,
                ),
                decoration: InputDecoration(
                  hintText: 'Search members by name, company, role...',
                  hintStyle: const TextStyle(
                    fontFamily: kFamilyName,
                    color: Color(0xFFB7BDC6),
                    fontSize: 13.5,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFB7BDC6), size: 22),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  border: _border(const Color(0xFFE6E8EC)),
                  enabledBorder: _border(const Color(0xFFE6E8EC)),
                  focusedBorder: _border(_orange),
                ),
              ),
            ),
          ),
          Expanded(
            child: members.when(
              loading: () => const Center(child: LoadingAnimation()),
              error: (_, __) => const Center(
                child: Text(
                  'Unable to load the team',
                  style: TextStyle(fontFamily: kFamilyName, color: _muted),
                ),
              ),
              data: (items) {
                final visible = items.where((member) {
                  if (_query.isEmpty) return true;
                  final role = _roleFor(member, roles).toLowerCase();
                  final company = _company(member).toLowerCase();
                  final name = (member.name ?? '').toLowerCase();
                  return name.contains(_query) ||
                      company.contains(_query) ||
                      role.contains(_query);
                }).toList();
                if (visible.isEmpty) {
                  return const Center(
                    child: Text(
                      'No members found',
                      style: TextStyle(fontFamily: kFamilyName, color: _muted),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: visible.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final member = visible[index];
                    return _TeamCard(
                      member: member,
                      role: _roleFor(member, roles),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
    );
  }

  String _roleFor(UserModel member, Map<String, String> roles) {
    final mapped = roles[member.uid ?? ''] ?? '';
    if (mapped.trim().isNotEmpty) return _title(mapped);
    final own = (member.role ?? '').trim();
    if (own.isNotEmpty && own.toLowerCase() != 'user') return _title(own);
    return 'Member';
  }

  String _company(UserModel member) {
    for (final company in member.company ?? const <Company>[]) {
      final name = (company.name ?? '').trim();
      if (name.isNotEmpty) return name;
    }
    return (member.businessCategory ?? '').trim();
  }

  String _title(String value) {
    return value
        .split(RegExp(r'[_\s]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
        .join(' ');
  }
}

class _TeamCard extends StatelessWidget {
  final UserModel member;
  final String role;

  const _TeamCard({required this.member, required this.role});

  @override
  Widget build(BuildContext context) {
    final name = (member.name ?? '').trim().isEmpty ? 'Member' : member.name!.trim();
    final company = _companyName();
    final phone = (member.phone ?? '').trim();
    final email = (member.email ?? '').trim();
    final location = (member.address ?? '').trim();
    final tags = (member.businessTags ?? const <String>[])
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .take(3)
        .toList();
    final highlighted = role.toLowerCase() != 'member';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0E000000), blurRadius: 14, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _avatar(name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: kFamilyName,
                              color: _ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: highlighted
                                ? const Color(0xFFFFF1E8)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            role,
                            style: TextStyle(
                              fontFamily: kFamilyName,
                              color: highlighted ? _orange : const Color(0xFF6B7280),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (company.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        company,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: kFamilyName,
                          color: _muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (phone.isNotEmpty) _line(Icons.phone_outlined, phone),
          if (email.isNotEmpty) _line(Icons.mail_outline, email),
          if (location.isNotEmpty) _line(Icons.location_on_outlined, location),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontFamily: kFamilyName,
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _action(Icons.phone_outlined, 'Call', () => _open('tel:${_digits(phone)}')),
              _action(Icons.chat_bubble_outline, 'WhatsApp', () => _openWhatsapp(phone)),
              _action(Icons.mail_outline, 'Email', () => _open('mailto:$email')),
              _action(Icons.share_outlined, 'Share', () => _share(name, company, phone, email)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatar(String name) {
    final image = member.image;
    final hasImage = image != null && image.trim().isNotEmpty;
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF1F2F4)),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initials(name),
            )
          : _initials(name),
    );
  }

  Widget _initials(String name) {
    final parts = name.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).take(2);
    final letters = parts.map((part) => part[0]).join().toUpperCase();
    return Center(
      child: Text(
        letters.isEmpty ? '?' : letters,
        style: const TextStyle(
          fontFamily: kFamilyName,
          color: _orange,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _line(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: kFamilyName,
                color: Color(0xFF4B5563),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _action(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF4B5563)),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: kFamilyName,
                  color: Color(0xFF6B7280),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _companyName() {
    for (final company in member.company ?? const <Company>[]) {
      final name = (company.name ?? '').trim();
      if (name.isNotEmpty) return name;
    }
    return (member.businessCategory ?? '').trim();
  }

  String _digits(String phone) => phone.replaceAll(RegExp(r'[^0-9+]'), '');

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openWhatsapp(String phone) async {
    final digits = _digits(phone).replaceAll('+', '');
    if (digits.isEmpty) return;
    await _open('https://wa.me/$digits');
  }

  Future<void> _share(String name, String company, String phone, String email) async {
    final lines = [
      name,
      if (role.isNotEmpty) role,
      if (company.isNotEmpty) company,
      if (phone.isNotEmpty) phone,
      if (email.isNotEmpty) email,
    ];
    await Share.share(lines.join('\n'));
  }
}
