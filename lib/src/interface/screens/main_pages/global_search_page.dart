import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hef/src/data/api_routes/search_api/search_api.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/chat_model.dart';
import 'package:hef/src/data/models/global_search_model.dart';
import 'package:hef/src/data/models/product_model.dart';
import 'package:hef/src/interface/components/ModalSheets/product_details.dart';
import 'package:hef/src/interface/components/common/community_chrome.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/screens/main_pages/chat/members.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/levels/level_members.dart';
import 'package:hef/src/interface/screens/main_pages/profile/profile_preview_withUserId.dart';

class GlobalSearchPage extends ConsumerStatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  ConsumerState<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends ConsumerState<GlobalSearchPage> {
  static const int _minQueryLength = 2;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final SearchApiService _searchApi = SearchApiService();

  Timer? _debounce;
  int _requestId = 0;

  String _query = '';
  bool _loading = false;
  String? _error;
  GlobalSearchResult _result = const GlobalSearchResult();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    final query = value.trim();
    setState(() => _query = query);
    _debounce?.cancel();

    if (query.length < _minQueryLength) {
      _requestId++;
      setState(() {
        _loading = false;
        _error = null;
        _result = const GlobalSearchResult();
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () {
      _runSearch(query);
    });
  }

  Future<void> _runSearch(String query) async {
    if (!mounted) return;

    final currentRequest = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _searchApi.globalSearch(query: query, limit: 10);
      if (!mounted || currentRequest != _requestId) return;

      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || currentRequest != _requestId) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _openMember(GlobalSearchMember member) {
    if (member.id.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfilePreviewUsingId(userId: member.id),
      ),
    );
  }

  Future<void> _openProduct(GlobalSearchProduct product) async {
    if (product.id.isEmpty) return;

    Participant receiver = Participant(
      id: product.seller,
      name: '',
      image: null,
    );

    final sellerId = product.seller ?? '';
    if (sellerId.isNotEmpty) {
      try {
        final owner =
            await ref.read(fetchUserDetailsProvider(sellerId).future);
        receiver = Participant(
          id: owner.uid,
          name: owner.name ?? '',
          image: owner.image,
        );
      } catch (_) {}
    }

    if (!mounted) return;

    openProductDetailsPage(
      context: context,
      product: Product(
        id: product.id,
        name: product.name,
        image: product.image.isEmpty ? null : product.image,
        price: product.price,
        offerPrice: product.offerPrice,
        seller: product.seller,
      ),
      sender: Participant(id: id),
      receiver: receiver,
    );
  }

  void _openCategory(GlobalSearchCategory category) {
    if (category.id.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MembersPage(
          initialCategoryId: category.id,
          initialCategoryName: category.name,
        ),
      ),
    );
  }

  void _openChapter(GlobalSearchChapter chapter) {
    if (chapter.id.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LevelMembers(
          chapterId: chapter.id,
          chapterName: chapter.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kCommunityText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Search',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: kCommunityText,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: CommunitySearchField(
              controller: _searchController,
              focusNode: _searchFocus,
              hint: 'Search members, category, chapter, product...',
              onChanged: _onQueryChanged,
              onSubmitted: (value) {
                _debounce?.cancel();
                final query = value.trim();
                setState(() => _query = query);
                if (query.length < _minQueryLength) {
                  _onQueryChanged(query);
                } else {
                  _runSearch(query);
                }
              },
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_query.isEmpty) {
      return const _EmptyState(
        icon: Icons.search_rounded,
        title: 'Search across HEF',
        subtitle: 'Find members, categories, chapters, and products.',
      );
    }

    if (_query.length < _minQueryLength) {
      return const _EmptyState(
        icon: Icons.keyboard_alt_outlined,
        title: 'Keep typing',
        subtitle: 'Enter at least 2 characters to search.',
      );
    }

    if (_loading && !_result.hasVisibleResults) {
      return const Center(child: LoadingAnimation());
    }

    if (_error != null && !_result.hasVisibleResults) {
      return _EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Something went wrong',
        subtitle: _error!,
        actionLabel: 'Retry',
        onAction: () => _runSearch(_query),
      );
    }

    if (!_loading && !_result.hasVisibleResults) {
      return const _EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No results found',
        subtitle: 'Try a different keyword.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 32),
      children: [
        if (_loading)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: LinearProgressIndicator(
              minHeight: 2,
              color: kPrimaryColor,
              backgroundColor: Color(0xFFFFEEDA),
            ),
          ),
        if (_result.members.isNotEmpty) ...[
          const _SectionHeader(
            title: 'Members',
            icon: Icons.people_alt_outlined,
          ),
          ..._result.members.map(
            (member) => _SearchTile(
              title: member.name.isEmpty ? 'Member' : member.name,
              subtitle: member.subtitle,
              leading: _Avatar(imageUrl: member.image),
              badge: 'Member',
              onTap: () => _openMember(member),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (_result.categories.isNotEmpty) ...[
          const _SectionHeader(
            title: 'Categories',
            icon: Icons.business_center_outlined,
          ),
          ..._result.categories.map(
            (category) => _SearchTile(
              title: category.name,
              subtitle: 'View members in this category',
              leading: const _IconBox(icon: Icons.business_center_outlined),
              badge: 'Category',
              onTap: () => _openCategory(category),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (_result.products.isNotEmpty) ...[
          const _SectionHeader(
            title: 'Products',
            icon: Icons.shopping_bag_outlined,
          ),
          ..._result.products.map(
            (product) => _SearchTile(
              title: product.name.isEmpty ? 'Product' : product.name,
              subtitle: product.subtitle,
              leading: _ProductThumb(imageUrl: product.image),
              badge: 'Product',
              onTap: () => _openProduct(product),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (_result.chapters.isNotEmpty) ...[
          const _SectionHeader(
            title: 'Chapters',
            icon: Icons.groups_outlined,
          ),
          ..._result.chapters.map(
            (chapter) => _SearchTile(
              title: chapter.name.isEmpty ? 'Chapter' : chapter.name,
              subtitle: chapter.shortCode.isEmpty
                  ? 'Chapter'
                  : chapter.shortCode,
              leading: const _IconBox(icon: Icons.groups_outlined),
              badge: 'Chapter',
              onTap: () => _openChapter(chapter),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: kPrimaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: kCommunityText,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget leading;
  final String badge;
  final VoidCallback onTap;

  const _SearchTile({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFEEEEF2)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kCommunityText,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF8B939E),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kCommunityOrangeSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: kCommunityMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? imageUrl;

  const _Avatar({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 44,
        height: 44,
        child: Image.network(
          imageUrl ?? '',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => SvgPicture.asset(
            'assets/svg/icons/dummy_person_small.svg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;

  const _IconBox({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: kCommunityOrangeSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: kPrimaryColor, size: 22),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  final String? imageUrl;

  const _ProductThumb({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Image.network(
          imageUrl ?? '',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFF2F2F2),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: kCommunityMuted,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: kCommunityHint),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: kCommunityText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: kCommunitySub,
                height: 1.35,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
