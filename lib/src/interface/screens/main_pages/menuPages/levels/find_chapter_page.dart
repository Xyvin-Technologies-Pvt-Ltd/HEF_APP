import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/chapter_api/chapter_details.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/models/chapter_directory_model.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/levels/chapter_detail_page.dart';

class FindChapterPage extends ConsumerStatefulWidget {
  const FindChapterPage({super.key});

  @override
  ConsumerState<FindChapterPage> createState() => _FindChapterPageState();
}

class _FindChapterPageState extends ConsumerState<FindChapterPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _district;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chapters = ref.watch(chapterDirectoryProvider);
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
          'Find Chapter',
          style: TextStyle(
            fontFamily: kFamilyName,
            color: Color(0xFF111111),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(child: _searchField()),
                const SizedBox(width: 12),
                _filterButton(chapters.valueOrNull ?? const []),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: chapters.when(
              data: (items) {
                final visible = _applyFilters(items);
                if (visible.isEmpty) {
                  return const Center(
                    child: Text(
                      'No chapters found',
                      style: TextStyle(
                        fontFamily: kFamilyName,
                        color: Color(0xFF8B93A0),
                        fontSize: 14,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: visible.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _ChapterCard(chapter: visible[index]);
                  },
                );
              },
              loading: () => const Center(child: LoadingAnimation()),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Unable to load chapters',
                        style: TextStyle(
                          fontFamily: kFamilyName,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => ref.invalidate(chapterDirectoryProvider),
                        child: const Text(
                          'Try again',
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<ChapterDirectoryItem> _applyFilters(List<ChapterDirectoryItem> items) {
    final query = _query.trim().toLowerCase();
    return items.where((chapter) {
      final matchesQuery = query.isEmpty ||
          chapter.name.toLowerCase().contains(query) ||
          chapter.location.toLowerCase().contains(query);
      final matchesDistrict =
          _district == null || chapter.districtName == _district;
      return matchesQuery && matchesDistrict;
    }).toList();
  }

  Widget _searchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value),
      style: const TextStyle(
        fontFamily: kFamilyName,
        fontSize: 14,
        color: Color(0xFF111111),
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Search by chapter Name',
        hintStyle: const TextStyle(
          fontFamily: kFamilyName,
          color: Color(0xFF9AA1AB),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: const Icon(Icons.search, color: Color(0xFFB0B6BE), size: 22),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 48),
        filled: true,
        fillColor: kWhite,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        constraints: const BoxConstraints(minHeight: 48, maxHeight: 48),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE6E8EC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE6E8EC)),
        ),
      ),
    );
  }

  Widget _filterButton(List<ChapterDirectoryItem> chapters) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: kWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: kPrimaryColor, width: 1.4),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _openFilters(chapters),
              child: const Center(
                child: Icon(Icons.tune, color: kPrimaryColor, size: 22),
              ),
            ),
          ),
          Positioned(
            top: -3,
            right: -3,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: kPrimaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openFilters(List<ChapterDirectoryItem> chapters) async {
    final districts = chapters
        .map((chapter) => chapter.districtName.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final selected = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: kWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Filter by district',
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
              if (districts.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Text(
                    'No districts available',
                    style: TextStyle(
                      fontFamily: kFamilyName,
                      color: Color(0xFF8B93A0),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: districts.length,
                    itemBuilder: (context, index) {
                      final district = districts[index];
                      final active = district == _district;
                      return ListTile(
                        title: Text(
                          district,
                          style: const TextStyle(
                            fontFamily: kFamilyName,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: active
                            ? const Icon(Icons.check, color: kPrimaryColor)
                            : null,
                        onTap: () => Navigator.pop(context, district),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (!mounted || selected == null) return;
    setState(() => _district = selected.isEmpty ? null : selected);
  }
}

class _ChapterCard extends StatelessWidget {
  final ChapterDirectoryItem chapter;

  const _ChapterCard({required this.chapter});

  @override
  Widget build(BuildContext context) {
    final membersLabel =
        chapter.memberCount == 1 ? '1 Member' : '${chapter.memberCount} Members';
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEF1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChapterDetailPage(chapter: chapter),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              _ChapterThumb(imageUrl: chapter.image),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: kFamilyName,
                        color: Color(0xFF111111),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.people_alt_outlined,
                          size: 15,
                          color: Color(0xFF9AA3AF),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            membersLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: kFamilyName,
                              color: Color(0xFF8B93A0),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFC5CAD1), size: 22),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _ChapterThumb extends StatelessWidget {
  final String? imageUrl;

  const _ChapterThumb({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final fallback = Image.asset(
      'assets/pngs/hef_logo_square.png',
      width: 52,
      height: 52,
      fit: BoxFit.cover,
    );
    final hasNetwork = imageUrl != null &&
        (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'));
    return ClipRRect(
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
    );
  }
}
