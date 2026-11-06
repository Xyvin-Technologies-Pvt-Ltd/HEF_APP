import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/services/launch_url.dart';
import 'package:hef/src/interface/components/common/community_chrome.dart';
import 'package:share_plus/share_plus.dart';

const Color _sheetInk = Color(0xFF12141A);
const Color _sheetMeta = Color(0xFF8E949E);
const Color _sheetTile = Color(0xFFFFF4EC);

String memberCompanyMeta(UserModel user, {String separator = ' | '}) {
  final company = (user.company != null && user.company!.isNotEmpty)
      ? user.company!.first.name?.trim()
      : null;
  final companyDesignation = (user.company != null &&
          user.company!.isNotEmpty &&
          (user.company!.first.designation?.trim().isNotEmpty ?? false))
      ? user.company!.first.designation!.trim()
      : null;
  final designation = (companyDesignation != null && companyDesignation.isNotEmpty)
      ? companyDesignation
      : user.designation?.trim();
  return [company, designation]
      .whereType<String>()
      .where((part) => part.isNotEmpty)
      .join(separator);
}

String memberChapterLabel(UserModel user) {
  final name = user.chapter?.name?.trim() ?? '';
  if (name.isEmpty) return '';
  if (name.toLowerCase().contains('chapter')) return name;
  return '$name Chapter';
}

class MemberDetailsSheet extends StatelessWidget {
  final UserModel user;
  final VoidCallback onMessage;
  final VoidCallback onViewProfile;

  const MemberDetailsSheet({
    super.key,
    required this.user,
    required this.onMessage,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    final name = (user.name ?? '').trim();
    final meta = memberCompanyMeta(user, separator: ' • ');
    final chapter = memberChapterLabel(user);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: SizedBox(
                    width: 42,
                    height: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFFD5D8DE),
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Member Details',
                        style: TextStyle(
                          fontFamily: kFamilyName,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _sheetInk,
                          height: 1.2,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      icon: const Icon(
                        Icons.close,
                        size: 22,
                        color: Color(0xFF8B9098),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: _avatar(user.image),
                      ),
                    ),
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
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: _sheetInk,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.check_circle,
                                size: 18,
                                color: kCommunityOrange,
                              ),
                            ],
                          ),
                          if (meta.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              meta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: kFamilyName,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: _sheetMeta,
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
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: _sheetMeta,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _action(
                      icon: Icons.chat_bubble_outline,
                      label: 'Message',
                      onTap: onMessage,
                    ),
                    const SizedBox(width: 10),
                    _action(
                      icon: Icons.phone_outlined,
                      label: 'Call',
                      onTap: () => _call(context),
                    ),
                    const SizedBox(width: 10),
                    _action(
                      icon: Icons.mail_outline,
                      label: 'Email',
                      onTap: () => _email(context),
                    ),
                    const SizedBox(width: 10),
                    _action(
                      icon: Icons.share_outlined,
                      label: 'Share',
                      onTap: () => _share(name, meta, chapter),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onViewProfile,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: kCommunityOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: kFamilyName,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('View Full Profile'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar(String? url) {
    final image = url?.trim() ?? '';
    if (!image.startsWith('http')) {
      return _avatarFallback();
    }
    return Image.network(
      image,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _avatarFallback(),
    );
  }

  Widget _avatarFallback() {
    return SvgPicture.asset(
      'assets/svg/icons/dummy_person_small.svg',
      width: 64,
      height: 64,
      fit: BoxFit.cover,
    );
  }

  Widget _action({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: _sheetTile,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 76,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: kCommunityOrange, size: 22),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: kFamilyName,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kCommunityOrange,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _phoneNumber() {
    final primary = user.phone?.trim();
    if (primary != null && primary.isNotEmpty) return primary;
    final business = user.secondaryPhone?.business?.trim();
    if (business != null && business.isNotEmpty) return business;
    for (final company in user.company ?? const <Company>[]) {
      final value = company.phone?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  String? _emailAddress() {
    final primary = user.email?.trim();
    if (primary != null && primary.isNotEmpty) return primary;
    for (final company in user.company ?? const <Company>[]) {
      final value = company.email?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  void _call(BuildContext context) {
    final phone = _phoneNumber();
    if (phone == null) {
      _missing(context, 'Phone number is not available');
      return;
    }
    launchPhone(phone);
  }

  void _email(BuildContext context) {
    final email = _emailAddress();
    if (email == null) {
      _missing(context, 'Email address is not available');
      return;
    }
    launchEmail(email);
  }

  Future<void> _share(String name, String meta, String chapter) async {
    final lines = <String>[
      if (name.isNotEmpty) name,
      if (meta.isNotEmpty) meta,
      if (chapter.isNotEmpty) chapter,
      if (_phoneNumber() != null) _phoneNumber()!,
      if (_emailAddress() != null) _emailAddress()!,
    ];
    if (lines.isEmpty) return;
    await Share.share(lines.join('\n'));
  }

  void _missing(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
