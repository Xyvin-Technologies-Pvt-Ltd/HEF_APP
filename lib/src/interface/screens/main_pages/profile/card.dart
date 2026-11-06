import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/services/save_qr.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

const Color _ink = Color(0xFF1C1F26);
const Color _muted = Color(0xFF8B939E);
const Color _orange = Color(0xFFFF6D00);
const Color _page = Color(0xFFF6F7F9);

class ProfileCard extends StatefulWidget {
  final UserModel user;
  const ProfileCard({super.key, required this.user});

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: _page,
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
          'Digital Membership Card',
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              children: [
                Screenshot(
                  controller: _screenshotController,
                  child: _card(user),
                ),
              ],
            ),
          ),
          Container(
            color: _page,
            padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + bottom),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _shareCard,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: _orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.ios_share, size: 18),
                      label: const Text(
                        'Share Card',
                        style: TextStyle(
                          fontFamily: kFamilyName,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => saveQr(screenshotController: _screenshotController),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _ink,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFE6E8EC)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: const Text(
                        'Save to Device',
                        style: TextStyle(
                          fontFamily: kFamilyName,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(UserModel user) {
    final company = _companyLine(user);
    final chapter = _chapterName(user);
    final memberSince = _memberSince(user);
    final role = _roleLabel(user);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/pngs/hef_logo_square.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'HINDU\nECONOMIC\nFORUM',
                style: TextStyle(
                  fontFamily: kFamilyName,
                  color: _ink,
                  fontSize: 9,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _avatar(user),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _text(user.name).isEmpty ? 'Member' : user.name!.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: kFamilyName,
                        color: _ink,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
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
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner, color: _orange, size: 16),
              SizedBox(width: 6),
              Text(
                'SCAN TO VERIFY',
                style: TextStyle(
                  fontFamily: kFamilyName,
                  color: _orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Present at forum events, conferences\n& chapter check-ins',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kFamilyName,
              color: _muted,
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          _qrFrame(user),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFBFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF0F1F3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _meta(Icons.badge_outlined, 'MEMBER ID', _memberId(user))),
                    Expanded(child: _meta(Icons.location_on_outlined, 'CHAPTER', chapter.isEmpty ? '—' : chapter)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _meta(
                        Icons.calendar_today_outlined,
                        'MEMBER SINCE',
                        memberSince.isEmpty ? '—' : memberSince,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4EC),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            role,
                            style: const TextStyle(
                              fontFamily: kFamilyName,
                              color: _orange,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(UserModel user) {
    final image = user.image;
    final hasImage = image != null && image.trim().isNotEmpty;
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF1F2F4),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasImage
                ? Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person, color: _muted, size: 30),
                  )
                : const Icon(Icons.person, color: _muted, size: 30),
          ),
          const Positioned(
            right: -2,
            bottom: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(1),
                child: Icon(Icons.verified, color: _orange, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qrFrame(UserModel user) {
    return SizedBox(
      width: 210,
      height: 210,
      child: Stack(
        children: [
          const Positioned(left: 0, top: 0, child: _Corner(top: true, left: true)),
          const Positioned(right: 0, top: 0, child: _Corner(top: true, left: false)),
          const Positioned(left: 0, bottom: 0, child: _Corner(top: false, left: true)),
          const Positioned(right: 0, bottom: 0, child: _Corner(top: false, left: false)),
          Center(
            child: QrImageView(
              data: 'https://admin.hefconnect.in/user/${user.uid ?? ''}',
              size: 168,
              padding: EdgeInsets.zero,
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: _orange),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: kFamilyName,
                  color: _muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: kFamilyName,
                  color: _ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _shareCard() async {
    final bytes = await _screenshotController.capture();
    if (bytes == null) return;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/hef_membership_card.png');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'HEF Digital Membership Card',
    );
  }

  String _companyLine(UserModel user) {
    Company? company;
    for (final item in user.company ?? const <Company>[]) {
      if (_text(item.name).isNotEmpty || _text(item.designation).isNotEmpty) {
        company = item;
        break;
      }
    }
    final name = _text(company?.name);
    final designation = _text(company?.designation);
    if (name.isEmpty && designation.isEmpty) return _text(user.designation);
    if (name.isEmpty) return designation;
    if (designation.isEmpty) return name;
    return '$name  •  $designation';
  }

  String _chapterName(UserModel user) {
    final chapter = _text(user.chapter?.name);
    if (chapter.isNotEmpty) return chapter;
    return _text(user.levelName);
  }

  String _memberId(UserModel user) {
    final id = _text(user.memberId);
    return id.isEmpty ? '—' : id;
  }

  String _memberSince(UserModel user) {
    final date = user.dateOfJoining ?? user.createdAt;
    if (date == null) return '';
    return '${date.year}';
  }

  String _roleLabel(UserModel user) {
    final role = _text(user.role);
    if (role.isEmpty) return 'Member';
    return role
        .split(RegExp(r'[_\s]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _text(String? value) => (value ?? '').trim();
}

class _Corner extends StatelessWidget {
  final bool top;
  final bool left;

  const _Corner({required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    const side = BorderSide(color: Color(0xFF1C1F26), width: 3);
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border(
          top: top ? side : BorderSide.none,
          bottom: top ? BorderSide.none : side,
          left: left ? side : BorderSide.none,
          right: left ? BorderSide.none : side,
        ),
      ),
    );
  }
}
