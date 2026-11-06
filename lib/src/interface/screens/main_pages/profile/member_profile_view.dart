import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hef/src/data/api_routes/review_api/review_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/chat_model.dart';
import 'package:hef/src/data/models/review_model.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/data/services/extract_level_details.dart';
import 'package:hef/src/data/services/launch_url.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/interface/components/ModalSheets/write_review.dart';
import 'package:hef/src/interface/screens/main_pages/chat/chat_screen.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MemberProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onShare;

  const MemberProfileAppBar({super.key, this.onShare});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: _ProfileColors.ink,
        ),
      ),
      title: const Text(
        'Member Profile',
        style: TextStyle(
          fontFamily: kFamilyName,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: _ProfileColors.ink,
        ),
      ),
      actions: [
        IconButton(
          onPressed: onShare,
          icon: Icon(
            Icons.ios_share,
            size: 22,
            color: onShare == null ? const Color(0xFFC7C7CC) : _ProfileColors.ink,
          ),
        ),
      ],
    );
  }
}

class MemberProfileStatusScaffold extends StatelessWidget {
  final bool loading;

  const MemberProfileStatusScaffold({super.key, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const MemberProfileAppBar(),
      body: Center(
        child: loading
            ? const CircularProgressIndicator(color: kPrimaryColor)
            : const Text(
                'Unable to load profile',
                style: TextStyle(
                  fontFamily: kFamilyName,
                  fontSize: 14,
                  color: _ProfileColors.muted,
                ),
              ),
      ),
    );
  }
}

class MemberProfileView extends ConsumerStatefulWidget {
  final UserModel user;

  const MemberProfileView({super.key, required this.user});

  @override
  ConsumerState<MemberProfileView> createState() => _MemberProfileViewState();
}

class _MemberProfileViewState extends ConsumerState<MemberProfileView> {
  late final PageController _videoController;
  int _reviewsToShow = 2;

  UserModel get user => widget.user;

  bool get _isOwnProfile => user.uid != null && user.uid == id;

  @override
  void initState() {
    super.initState();
    _videoController = PageController();
  }

  @override
  void didUpdateWidget(covariant MemberProfileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.uid != widget.user.uid) {
      _reviewsToShow = 2;
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final asyncReviews = ref.watch(
      fetchReviewsProvider(userId: user.uid ?? ''),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MemberProfileAppBar(onShare: _shareProfile),
      bottomNavigationBar: _bottomBar(bottomInset),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _header(),
          if (_showMemberCard) ...[
            const SizedBox(height: 16),
            _memberCard(),
          ],
          if (_phones.isNotEmpty || _hasText(user.email) || _hasText(user.address)) ...[
            const SizedBox(height: 22),
            _sectionTitle('Contact Information'),
            const SizedBox(height: 12),
            _contactBlock(),
          ],
          if (_hasText(user.bio)) ...[
            const SizedBox(height: 22),
            _sectionTitle('About'),
            const SizedBox(height: 10),
            Text(
              user.bio!.trim(),
              style: _text(size: 13.5, color: _ProfileColors.body, height: 1.45),
            ),
          ],
          _feedbackSection(asyncReviews),
          if (user.social?.isNotEmpty == true) ...[
            const SizedBox(height: 22),
            _sectionTitle('Social Media'),
            const SizedBox(height: 6),
            for (final social in user.social!)
              if (_hasText(social.name) || _hasText(social.link)) _socialRow(social),
          ],
          if (user.websites?.isNotEmpty == true) ...[
            const SizedBox(height: 22),
            _sectionTitle('Website & Links'),
            const SizedBox(height: 6),
            for (final website in user.websites!)
              if (_hasText(website.name) || _hasText(website.link))
                _websiteRow(website),
          ],
          if (user.videos?.isNotEmpty == true) ...[
            const SizedBox(height: 22),
            _sectionTitle('Featured Video'),
            const SizedBox(height: 12),
            _videoCarousel(),
          ],
          if (user.certificates?.isNotEmpty == true) ...[
            const SizedBox(height: 22),
            _sectionTitle('Certificates'),
            const SizedBox(height: 12),
            for (var i = 0; i < user.certificates!.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _certificateCard(user.certificates![i]),
            ],
          ],
          if (user.awards?.isNotEmpty == true) ...[
            const SizedBox(height: 22),
            _sectionTitle('Awards'),
            const SizedBox(height: 12),
            _awardsGrid(),
          ],
          if (_documents.isNotEmpty) ...[
            const SizedBox(height: 22),
            _sectionTitle('Documents'),
            const SizedBox(height: 12),
            for (var i = 0; i < _documents.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _documentRow(_documents[i]),
            ],
          ],
        ],
      ),
    );
  }

  Widget _header() {
    final company = _companyLine;
    final chapter = _chapterName;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _avatar(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _hasText(user.name) ? user.name!.trim() : 'Member',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _text(size: 18, weight: FontWeight.w700, height: 1.2),
              ),
              if (company.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  company,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _text(size: 13, color: _ProfileColors.muted, height: 1.3),
                ),
              ],
              if (chapter.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  chapter,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _text(
                    size: 13,
                    weight: FontWeight.w600,
                    color: kPrimaryColor,
                    height: 1.2,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_isOwnProfile)
          Material(
            color: const Color(0xFFFFF1E8),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => NavigationService().pushNamed('EditUser'),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.edit_outlined, color: kPrimaryColor, size: 18),
              ),
            ),
          ),
      ],
    );
  }

  Widget _avatar() {
    final image = user.image;
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF3F3F3),
      ),
      clipBehavior: Clip.antiAlias,
      child: _hasText(image)
          ? Image.network(
              image!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _avatarFallback(),
            )
          : _avatarFallback(),
    );
  }

  Widget _avatarFallback() {
    return SvgPicture.asset(
      'assets/svg/icons/dummy_person_large.svg',
      fit: BoxFit.cover,
    );
  }

  bool get _showMemberCard => _hasText(user.memberId) || _memberSince.isNotEmpty;

  Widget _memberCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _ProfileColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const CustomPaint(
              size: Size(22, 18),
              painter: _IdCardPainter(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_hasText(user.memberId))
                  Text(
                    'Member ID - ${user.memberId!.trim()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _text(size: 14.5, weight: FontWeight.w700, height: 1.2),
                  ),
                if (_memberSince.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    _memberSince,
                    style: _text(size: 12, color: _ProfileColors.muted, height: 1.2),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactBlock() {
    final rows = <Widget>[];
    for (final phone in _phones) {
      rows.add(_contactRow(
        icon: Icons.phone_outlined,
        label: phone,
        onTap: () => launchPhone(phone),
      ));
    }
    if (_hasText(user.email)) {
      rows.add(_contactRow(
        icon: Icons.mail_outline_rounded,
        label: user.email!.trim(),
        onTap: () => launchEmail(user.email!.trim()),
      ));
    }
    if (_hasText(user.address)) {
      rows.add(_contactRow(
        icon: Icons.location_on_outlined,
        label: user.address!.trim(),
        alignTop: true,
        onTap: () => openGoogleMaps(user.address!.trim()),
      ));
    }
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          rows[i],
        ],
      ],
    );
  }

  Widget _contactRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool alignTop = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment:
            alignTop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: alignTop ? 1 : 0),
            child: Icon(icon, color: kPrimaryColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: _text(size: 14, color: _ProfileColors.body, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feedbackSection(AsyncValue<List<ReviewModel>> asyncReviews) {
    if (!_hasText(user.uid)) {
      return const SizedBox.shrink();
    }
    return asyncReviews.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (reviews) {
        final hasReviews = reviews.isNotEmpty;
        if (!hasReviews && _isOwnProfile) return const SizedBox.shrink();
        final visible = reviews.take(_reviewsToShow).toList();
        return Padding(
          padding: const EdgeInsets.only(top: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _sectionTitle('Member Feedback')),
                  if (!_isOwnProfile)
                    GestureDetector(
                      onTap: _writeReview,
                      child: Text(
                        'Write a review',
                        style: _text(
                          size: 13,
                          weight: FontWeight.w600,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                ],
              ),
              if (hasReviews) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 136,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) =>
                        _feedbackCard(visible[index]),
                  ),
                ),
              ],
              if (_reviewsToShow < reviews.length)
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _reviewsToShow =
                            (_reviewsToShow + 2).clamp(0, reviews.length);
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'View more',
                      style: _text(
                        size: 14,
                        weight: FontWeight.w600,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _feedbackCard(ReviewModel review) {
    final width = MediaQuery.sizeOf(context).width * 0.62;
    final rating = (review.rating ?? 0).clamp(0, 5);
    final reviewerImage = review.reviewer?.image;
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _ProfileColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF3F3F3),
                ),
                clipBehavior: Clip.antiAlias,
                child: _hasText(reviewerImage)
                    ? Image.network(
                        reviewerImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _smallAvatarFallback(),
                      )
                    : _smallAvatarFallback(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hasText(review.reviewer?.name)
                          ? review.reviewer!.name!.trim()
                          : 'Member',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _text(size: 13, weight: FontWeight.w700, height: 1.2),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 14,
                          color: kPrimaryColor,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              review.comment?.trim() ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: _text(size: 12, color: _ProfileColors.muted, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallAvatarFallback() {
    return SvgPicture.asset(
      'assets/svg/icons/dummy_person_small.svg',
      fit: BoxFit.cover,
    );
  }

  Widget _socialRow(Link social) {
    return InkWell(
      onTap: _hasText(social.link) ? () => launchURL(social.link!) : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _socialIcon('${social.name ?? ''} ${social.link ?? ''}'),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _hasText(social.name) ? social.name!.trim() : (social.link ?? ''),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _text(size: 14, color: _ProfileColors.body),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialIcon(String name) {
    final key = name.toLowerCase();
    if (key.contains('linkedin')) {
      return _brandBox(FontAwesomeIcons.linkedinIn, const Color(0xFF0A66C2));
    }
    if (key.contains('insta')) {
      return _instagramBox();
    }
    if (key.contains('twitter') || key.contains('x.com') || key.trim() == 'x') {
      return _brandBox(FontAwesomeIcons.twitter, const Color(0xFF111111));
    }
    if (key.contains('facebook')) {
      return _brandBox(FontAwesomeIcons.facebookF, const Color(0xFF1877F2));
    }
    if (key.contains('youtube')) {
      return _brandBox(FontAwesomeIcons.youtube, const Color(0xFFFF0000));
    }
    if (key.contains('whatsapp')) {
      return _brandBox(FontAwesomeIcons.whatsapp, const Color(0xFF25D366));
    }
    return const Icon(Icons.public, color: kPrimaryColor, size: 20);
  }

  Widget _brandBox(FaIconData icon, Color color) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      alignment: Alignment.center,
      child: FaIcon(icon, size: 12, color: Colors.white),
    );
  }

  Widget _instagramBox() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Color(0xFFFEDA75),
            Color(0xFFFA7E1E),
            Color(0xFFD62976),
            Color(0xFF962FBF),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: const FaIcon(FontAwesomeIcons.instagram, size: 12, color: Colors.white),
    );
  }

  Widget _websiteRow(Link website) {
    return InkWell(
      onTap: _hasText(website.link) ? () => launchURL(website.link!) : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.language, color: kPrimaryColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _hasText(website.name) ? website.name!.trim() : (website.link ?? ''),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _text(size: 14, color: _ProfileColors.body),
              ),
            ),
            const Icon(Icons.open_in_new_rounded, size: 16, color: Color(0xFFB0B0B0)),
          ],
        ),
      ),
    );
  }

  Widget _videoCarousel() {
    final videos = user.videos!;
    return Column(
      children: [
        SizedBox(
          height: 188,
          child: PageView.builder(
            controller: _videoController,
            itemCount: videos.length,
            itemBuilder: (context, index) => _videoCard(videos[index]),
          ),
        ),
        if (videos.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SmoothPageIndicator(
              controller: _videoController,
              count: videos.length,
              effect: const ExpandingDotsEffect(
                dotHeight: 6,
                dotWidth: 6,
                expansionFactor: 2.6,
                spacing: 5,
                activeDotColor: kPrimaryColor,
                dotColor: Color(0xFFD5D5D5),
              ),
            ),
          ),
      ],
    );
  }

  Widget _videoCard(Link video) {
    final videoId = YoutubePlayer.convertUrlToId(video.link ?? '');
    final thumb = videoId == null
        ? null
        : 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    return GestureDetector(
      onTap: () => _openVideo(video),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (thumb != null)
              Image.network(
                thumb,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: const Color(0xFF2A2A2A)),
              )
            else
              Container(color: const Color(0xFF2A2A2A)),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x33000000), Color(0x99000000)],
                ),
              ),
            ),
            Center(
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xF2FFFFFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: _ProfileColors.ink,
                  size: 30,
                ),
              ),
            ),
            if (_hasText(video.name))
              Positioned(
                left: 12,
                right: 16,
                bottom: 12,
                child: Text(
                  video.name!.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _text(
                    size: 13,
                    weight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _certificateCard(Link certificate) {
    final title = _hasText(certificate.name) ? certificate.name!.trim() : 'Certificate';
    return GestureDetector(
      onTap: () => _openCertificate(certificate),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6C98A), width: 1.3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF0D7A2)),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_rounded, size: 11, color: Color(0xFFE0B15A)),
                      SizedBox(width: 8),
                      SizedBox(
                        width: 36,
                        child: Divider(color: Color(0xFFE0B15A), thickness: 0.8),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.star_rounded, size: 11, color: Color(0xFFE0B15A)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'GreatVibes',
                        fontSize: 36,
                        color: Color(0xFFD4891A),
                        height: 1.05,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _hasText(user.name) ? user.name!.trim() : '',
                    textAlign: TextAlign.center,
                    style: _text(size: 13, color: _ProfileColors.muted),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
              const Positioned(
                right: 0,
                bottom: 0,
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFE6B325),
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _awardsGrid() {
    final awards = user.awards!;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: awards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        final award = awards[index];
        return GestureDetector(
          onTap: () => _showAwardDialog(award),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _hasText(award.image)
                      ? Image.network(
                          award.image!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: const Color(0xFFEDEDED)),
                        )
                      : Container(color: const Color(0xFFEDEDED)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                award.name?.trim() ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _text(size: 13, weight: FontWeight.w700, height: 1.2),
              ),
              if (_hasText(award.authority))
                Text(
                  award.authority!.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _text(size: 11, color: _ProfileColors.muted, height: 1.3),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _documentRow(String url) {
    final name = _fileName(url);
    final isPdf = name.toLowerCase().endsWith('.pdf');
    return InkWell(
      onTap: () => launchURL(url),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isPdf ? const Color(0xFFE53935) : kPrimaryColor,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              isPdf ? 'PDF' : 'FILE',
              style: _text(
                size: isPdf ? 10 : 8,
                weight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _text(size: 14, weight: FontWeight.w500),
            ),
          ),
          const Icon(Icons.file_download_outlined, size: 20, color: Color(0xFF9A9A9A)),
        ],
      ),
    );
  }

  Widget _bottomBar(double bottomInset) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottomInset),
      child: Row(
        children: [
          if (!_isOwnProfile)
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _onSecondaryAction,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kPrimaryColor, width: 1.4),
                ),
                alignment: Alignment.center,
                child: const CustomPaint(
                  size: Size(22, 14),
                  painter: _ConnectPainter(),
                ),
              ),
            ),
          ),
          if (!_isOwnProfile) const SizedBox(width: 12),
          Expanded(
            child: Material(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _shareProfile,
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 52,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.ios_share, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Share Profile',
                        style: _text(
                          size: 16,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: _text(size: 16, weight: FontWeight.w700, height: 1.2),
    );
  }

  Future<void> _shareProfile() async {
    final lines = <String>[
      if (_hasText(user.name)) user.name!.trim(),
      if (_companyLine.isNotEmpty) _companyLine,
      if (_chapterName.isNotEmpty) _chapterName,
      if (_hasText(user.memberId)) 'Member ID - ${user.memberId!.trim()}',
      if (_hasText(user.phone)) user.phone!.trim(),
      if (_hasText(user.email)) user.email!.trim(),
    ];
    if (lines.isEmpty) return;
    await Share.share(lines.join('\n'));
  }

  void _onSecondaryAction() {
    if (_isOwnProfile) {
      NavigationService().pushNamed('EditUser');
      return;
    }
    final receiver = Participant(
      id: user.uid,
      image: user.image ?? '',
      name: user.name,
    );
    final sender = Participant(id: id);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => IndividualPage(
          receiver: receiver,
          sender: sender,
        ),
      ),
    );
  }

  void _writeReview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ShowWriteReviewSheet(userId: user.uid ?? ''),
    );
  }

  void _openVideo(Link video) {
    final videoUrl = video.link ?? '';
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    if (videoId == null || videoId.isEmpty) {
      if (videoUrl.isNotEmpty) launchURL(videoUrl);
      return;
    }
    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
      ),
    );
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.black.withValues(alpha: 0.9),
          insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SizedBox(
            width: MediaQuery.sizeOf(dialogContext).width,
            height: MediaQuery.sizeOf(dialogContext).height * 0.7,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          video.name ?? 'Video',
                          style: _text(size: 16, weight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.black,
                    margin: const EdgeInsets.all(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: YoutubePlayer(
                        controller: controller,
                        aspectRatio: 16 / 9,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: kPrimaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _openCertificate(Link certificate) {
    final link = certificate.link ?? '';
    if (link.isEmpty) return;
    final isImage = RegExp(r'\.(png|jpe?g|webp|gif)(\?|$)', caseSensitive: false)
        .hasMatch(link);
    if (!isImage) {
      launchURL(link);
      return;
    }
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  link,
                  width: double.infinity,
                  height: 360,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox(
                    height: 160,
                    child: Center(child: Icon(Icons.broken_image_outlined)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  certificate.name ?? '',
                  textAlign: TextAlign.center,
                  style: _text(size: 18, weight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAwardDialog(Award award) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: _hasText(award.image)
                    ? Image.network(
                        award.image!,
                        width: double.infinity,
                        height: 260,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(height: 160, color: const Color(0xFFEDEDED)),
                      )
                    : Container(height: 160, color: const Color(0xFFEDEDED)),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      award.name ?? '',
                      style: _text(size: 18, weight: FontWeight.w700),
                    ),
                    if (_hasText(award.authority)) ...[
                      const SizedBox(height: 6),
                      Text(
                        award.authority!,
                        style: _text(size: 14, color: _ProfileColors.muted),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> get _phones {
    final values = <String>[];
    void add(String? value) {
      if (!_hasText(value)) return;
      final trimmed = value!.trim();
      if (!values.contains(trimmed)) values.add(trimmed);
    }

    add(user.phone);
    add(user.secondaryPhone?.business);
    add(user.secondaryPhone?.whatsapp);
    return values;
  }

  List<String> get _documents {
    return (user.file ?? const <String>[])
        .where((file) => _hasText(file))
        .map((file) => file.trim())
        .toList();
  }

  String get _companyLine {
    String? companyName;
    String? designation = _hasText(user.designation) ? user.designation!.trim() : null;
    for (final company in user.company ?? const <Company>[]) {
      if (_hasText(company.name)) companyName = company.name!.trim();
      if (_hasText(company.designation)) designation = company.designation!.trim();
      if (companyName != null) break;
    }
    final parts = <String>[
      if (companyName != null && companyName.isNotEmpty) companyName,
      if (designation != null && designation.isNotEmpty) designation,
    ];
    if (parts.isEmpty && _hasText(user.role)) return user.role!.trim();
    return parts.join(' • ');
  }

  String get _chapterName {
    final modelName = user.chapter?.name?.trim();
    if (_hasText(modelName)) return _withChapterSuffix(modelName!);
    final level = user.level?.trim() ?? '';
    if (level.isEmpty) return '';
    try {
      final data = extractLevelDetails(level);
      final name = data['chapterName']?.trim() ?? '';
      if (name.isEmpty) return '';
      return _withChapterSuffix(name);
    } catch (_) {
      return '';
    }
  }

  String _withChapterSuffix(String name) {
    if (name.toLowerCase().contains('chapter')) return name;
    return '$name Chapter';
  }

  String get _memberSince {
    final date = user.dateOfJoining ?? user.createdAt;
    if (date == null) return '';
    return 'Member Since ${DateFormat('MMM yyyy').format(date)}';
  }

  String _fileName(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.pathSegments.isEmpty) return url;
      return Uri.decodeComponent(uri.pathSegments.last);
    } catch (_) {
      return url;
    }
  }

  bool _hasText(String? value) {
    if (value == null) return false;
    final trimmed = value.trim();
    return trimmed.isNotEmpty && trimmed.toLowerCase() != 'null';
  }
}

TextStyle _text({
  double size = 14,
  FontWeight weight = FontWeight.w400,
  Color color = _ProfileColors.ink,
  double height = 1.2,
}) {
  return TextStyle(
    fontFamily: kFamilyName,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );
}

class _ProfileColors {
  static const ink = Color(0xFF1C1C1E);
  static const body = Color(0xFF3A3A3C);
  static const muted = Color(0xFF8E8E93);
  static const line = Color(0xFFEFEFEF);
}

class _IdCardPainter extends CustomPainter {
  const _IdCardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = Colors.white;
    final card = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.8, 0.8, size.width - 1.6, size.height - 1.6),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(card, stroke);
    canvas.drawCircle(Offset(size.width * 0.30, size.height * 0.42), 2.1, fill);
    canvas.drawLine(
      Offset(size.width * 0.46, size.height * 0.36),
      Offset(size.width * 0.78, size.height * 0.36),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.46, size.height * 0.58),
      Offset(size.width * 0.70, size.height * 0.58),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ConnectPainter extends CustomPainter {
  const _ConnectPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = kPrimaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = kPrimaryColor;
    final y = size.height / 2;
    final left = Offset(size.width * 0.22, y);
    final right = Offset(size.width * 0.78, y);
    canvas.drawLine(left, right, stroke);
    canvas.drawCircle(left, 3.1, fill);
    canvas.drawCircle(right, 3.1, fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
