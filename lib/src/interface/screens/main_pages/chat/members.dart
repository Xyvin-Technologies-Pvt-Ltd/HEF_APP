import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hef/src/data/api_routes/chat_api/chat_api.dart';
import 'package:hef/src/data/api_routes/levels_api/levels_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/chat_model.dart';
import 'package:hef/src/data/notifiers/people_notifier.dart';
import 'package:hef/src/data/notifiers/business_category_notifier.dart';
import 'package:hef/src/interface/components/common/community_chrome.dart';

import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/screens/main_pages/chat/chat_screen.dart';
import 'package:hef/src/interface/screens/main_pages/chat/member_details_sheet.dart';
import 'package:hef/src/interface/screens/main_pages/profile/profile_preview.dart';
import 'package:hef/src/data/models/user_model.dart';

import 'dart:async';

class MembersPage extends ConsumerStatefulWidget {
  const MembersPage({super.key});

  @override
  ConsumerState<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends ConsumerState<MembersPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _debounce;
  String? selectedDistrictId;
  String? selectedDistrictName;
  String? selectedChapterId;
  String? selectedCategoryId;
  String? selectedCategoryName;
  String? selectedChapter;
  String? businessTagSearch;
  List<String> selectedTags = [];
  String _directoryFilter = 'chapter';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchInitialUsers();
    _fetchCategories();
  }

  Future<void> _fetchInitialUsers() async {
    await ref.read(peopleNotifierProvider.notifier).fetchMoreUsers();
  }

  Future<void> _fetchCategories() async {
    await ref
        .read(businessCategoryNotifierProvider.notifier)
        .fetchMoreCategories();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      ref.read(peopleNotifierProvider.notifier).fetchMoreUsers();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(peopleNotifierProvider.notifier).searchUsers(query,
          districtFilter: selectedDistrictId,
          chapterFilter: selectedChapterId,
          categoryFilter: selectedCategoryId,
          tagsFilter: selectedTags.isNotEmpty ? selectedTags : null);
    });
  }

  void _onSearchSubmitted(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(peopleNotifierProvider.notifier).searchUsers(query,
          districtFilter: selectedDistrictId,
          chapterFilter: selectedChapterId,
          categoryFilter: selectedCategoryId,
          tagsFilter: selectedTags.isNotEmpty ? selectedTags : null);
    });
  }

  void _showFilterBottomSheet() {
    String? tempDistrictId = selectedDistrictId;
    String? tempDistrictName = selectedDistrictName;
    String? tempChapterId = selectedChapterId;
    String? tempChapterName = selectedChapter;
    String? tempCategoryName = selectedCategoryName;
    String? tempCategoryId = selectedCategoryId;
    final tempTags = List<String>.from(selectedTags);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(businessCategoryNotifierProvider.notifier).fetchMoreCategories();
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x66000000),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 18,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFB2B5BE),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Filter',
                                style: TextStyle(
                                  fontFamily: kFamilyName,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF12141A),
                                  height: 1.2,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setSheetState(() {
                                  tempDistrictId = null;
                                  tempDistrictName = null;
                                  tempChapterId = null;
                                  tempChapterName = null;
                                  tempCategoryName = null;
                                  tempCategoryId = null;
                                  tempTags.clear();
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: kPrimaryColor,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 32),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                textStyle: const TextStyle(
                                  fontFamily: kFamilyName,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text('Clear All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        const _FilterLabel('Chapter'),
                        const SizedBox(height: 8),
                        _FilterField(
                          icon: Icons.map_outlined,
                          hint: 'Select Chapter',
                          value: tempChapterName,
                          onTap: () async {
                            final choice = await _openFilterPicker(
                              title: 'Select Chapter',
                              selectedId: tempChapterId,
                              kind: _MemberFilterKind.chapter,
                            );
                            if (!sheetContext.mounted || choice == null) return;
                            setSheetState(() {
                              tempChapterId = choice.id;
                              tempChapterName = choice.label;
                            });
                          },
                        ),
                        const SizedBox(height: 18),
                        const _FilterLabel('Business Category'),
                        const SizedBox(height: 8),
                        _FilterField(
                          icon: Icons.work_outline,
                          hint: 'Select Business Category',
                          value: tempCategoryName,
                          onTap: () async {
                            final choice = await _openFilterPicker(
                              title: 'Select Business Category',
                              selectedId: tempCategoryId,
                              kind: _MemberFilterKind.category,
                            );
                            if (!sheetContext.mounted || choice == null) return;
                            setSheetState(() {
                              tempCategoryId = choice.id;
                              tempCategoryName = choice.label;
                            });
                          },
                        ),
                        const SizedBox(height: 18),
                        const _FilterLabel('District'),
                        const SizedBox(height: 8),
                        _FilterField(
                          icon: Icons.location_on_outlined,
                          hint: 'Select District',
                          value: tempDistrictName,
                          onTap: () async {
                            final choice = await _openFilterPicker(
                              title: 'Select District',
                              selectedId: tempDistrictId,
                              kind: _MemberFilterKind.district,
                            );
                            if (!sheetContext.mounted || choice == null) return;
                            setSheetState(() {
                              tempDistrictId = choice.id;
                              tempDistrictName = choice.label;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: TextButton(
                                  onPressed: () => Navigator.pop(sheetContext),
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFECE6),
                                    foregroundColor: kPrimaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    textStyle: const TextStyle(
                                      fontFamily: kFamilyName,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedDistrictId = tempDistrictId;
                                      selectedDistrictName = tempDistrictName;
                                      selectedChapterId = tempChapterId;
                                      selectedChapter = tempChapterName;
                                      selectedCategoryName = tempCategoryName;
                                      selectedCategoryId = tempCategoryId;
                                      selectedTags
                                        ..clear()
                                        ..addAll(tempTags);
                                    });
                                    ref
                                        .read(peopleNotifierProvider.notifier)
                                        .searchUsers(
                                          _searchController.text,
                                          districtFilter: tempDistrictId,
                                          chapterFilter: tempChapterId,
                                          categoryFilter: tempCategoryId,
                                          tagsFilter: tempTags.isNotEmpty
                                              ? tempTags
                                              : null,
                                        );
                                    Navigator.pop(sheetContext);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: kPrimaryColor,
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
                                  child: const Text('Apply'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<_FilterChoice?> _openFilterPicker({
    required String title,
    required String? selectedId,
    required _MemberFilterKind kind,
  }) {
    return showModalBottomSheet<_FilterChoice>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _MemberFilterPicker(
          title: title,
          selectedId: selectedId,
          kind: kind,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(peopleNotifierProvider);
    final isLoading = ref.read(peopleNotifierProvider.notifier).isLoading;
    final isFirstLoad = ref.read(peopleNotifierProvider.notifier).isFirstLoad;

    // Sort users alphabetically by name (case-insensitive)
    final sortedUsers = users.toList()
      ..sort((a, b) {
        // Handle null/empty names by treating them as empty strings
        final nameA = (a.name ?? '').trim().toLowerCase();
        final nameB = (b.name ?? '').trim().toLowerCase();

        // If both names are empty, they are equal
        if (nameA.isEmpty && nameB.isEmpty) return 0;

        // Empty names should come last
        if (nameA.isEmpty) return 1;
        if (nameB.isEmpty) return -1;

        return nameA.compareTo(nameB);
      });

    final asyncChats = ref.watch(fetchChatThreadProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 8),
          CommunitySearchRow(
            controller: _searchController,
            focusNode: _searchFocus,
            hint: 'Search by Name, city, state...',
            onChanged: _onSearchChanged,
            onSubmitted: _onSearchSubmitted,
            onFilter: _showFilterBottomSheet,
            filterActive: true,
          ),
          _buildDirectoryFilters(),
          Expanded(
            child: isFirstLoad
                ? const Center(child: LoadingAnimation())
                : sortedUsers.isEmpty
                    ? const Center(
                        child: Text(
                          'No Members Found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 4, bottom: 110),
                itemCount: sortedUsers.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == sortedUsers.length) {
                    return const Center(child: LoadingAnimation());
                  }
                  final user = sortedUsers[index];
                  final asyncUserChat = asyncChats.when(
                    data: (chats) {
                      final chatForUser = chats.firstWhere(
                        (chat) =>
                            chat.participants?.any((p) => p.id == user.uid) ??
                            false,
                        orElse: () => ChatModel(
                          participants: [
                            Participant(
                              id: user.uid,
                              name: user.name ?? '',
                              image: user.image ?? '',
                            ),
                            Participant(id: id),
                          ],
                        ),
                      );

                      final receiver = chatForUser.participants?.firstWhere(
                        (p) => p.id != id,
                        orElse: () => Participant(
                          id: user.uid,
                          name: user.name ?? '',
                          image: user.image,
                        ),
                      );
                      final sender = chatForUser.participants?.firstWhere(
                        (p) => p.id == id,
                        orElse: () => Participant(),
                      );

                      return _memberCard(
                        user: user,
                        onOpen: () => _openMemberDetails(
                          user,
                          onMessage: () => _openDirectChat(
                            receiver: receiver!,
                            sender: sender!,
                          ),
                        ),
                        onChat: () => _openDirectChat(
                          receiver: receiver!,
                          sender: sender!,
                        ),
                      );
                    },
                    loading: () => _memberCard(
                      user: user,
                      onOpen: () => _openMemberDetails(
                        user,
                        onMessage: () => _openDirectChat(
                          receiver: Participant(
                            id: user.uid,
                            name: user.name ?? '',
                            image: user.image,
                          ),
                          sender: Participant(id: id),
                        ),
                      ),
                      onChat: () => _openDirectChat(
                        receiver: Participant(
                          id: user.uid,
                          name: user.name ?? '',
                          image: user.image,
                        ),
                        sender: Participant(id: id),
                      ),
                    ),
                    error: (_, __) => _memberCard(
                      user: user,
                      onOpen: () => _openMemberDetails(user, onMessage: () {}),
                      onChat: () {},
                    ),
                  );

                  return asyncUserChat;
                },
              ),
          ),
        ],
      ),
    );
  }

  void _openDirectChat({
    required Participant receiver,
    required Participant sender,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => IndividualPage(
          receiver: receiver,
          sender: sender,
        ),
      ),
    );
  }

  void _openMemberDetails(UserModel user, {required VoidCallback onMessage}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x66000000),
      builder: (sheetContext) {
        return MemberDetailsSheet(
          user: user,
          onMessage: () {
            Navigator.pop(sheetContext);
            onMessage();
          },
          onViewProfile: () {
            Navigator.pop(sheetContext);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProfilePreview(user: user),
              ),
            );
          },
        );
      },
    );
  }

  void _applyDirectoryFilters() {
    ref.read(peopleNotifierProvider.notifier).searchUsers(
          _searchController.text,
          districtFilter: selectedDistrictId,
          chapterFilter: selectedChapterId,
          categoryFilter: selectedCategoryId,
          tagsFilter: selectedTags.isNotEmpty ? selectedTags : null,
        );
  }

  void _resetDirectory() {
    setState(() {
      selectedDistrictId = null;
      selectedDistrictName = null;
      selectedChapterId = null;
      selectedChapter = null;
      selectedCategoryId = null;
      selectedCategoryName = null;
      selectedTags = [];
    });
    _applyDirectoryFilters();
  }

  Widget _modeChip({
    required String label,
    required IconData icon,
    required String mode,
  }) {
    final selected = _directoryFilter == mode;
    final color = selected ? kCommunityOrange : const Color(0xFF6B7280);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _directoryFilter = mode),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: selected ? kCommunityOrangeSoft : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? kCommunityOrange : kCommunityBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _choiceChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 170),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? kCommunityNavy : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? kCommunityNavy : const Color(0xFFE5E7EB),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF4B5563),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDirectoryFilters() {
    final showingLabel = _directoryFilter == 'category'
        ? 'categories'
        : _directoryFilter == 'district'
            ? 'districts'
            : 'chapters';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              _modeChip(
                label: 'Chapter',
                icon: Icons.people_alt_outlined,
                mode: 'chapter',
              ),
              const SizedBox(width: 8),
              _modeChip(
                label: 'Business Category',
                icon: Icons.business_center_outlined,
                mode: 'category',
              ),
              const SizedBox(width: 8),
              _modeChip(
                label: 'District',
                icon: Icons.location_on_outlined,
                mode: 'district',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 38,
          child: _directoryFilter == 'category'
              ? _categoryChips()
              : _directoryFilter == 'district'
                  ? _districtChips()
                  : _chapterChips(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Showing $_directoryCount $showingLabel',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _resetDirectory,
                behavior: HitTestBehavior.opaque,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 16,
                      color: kCommunityOrange,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Reset',
                      style: TextStyle(
                        color: kCommunityOrange,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _directoryCount = 0;

  Widget _chapterChips() {
    final asyncChapters = ref.watch(fetchChaptersProvider);
    return asyncChapters.when(
      data: (chapters) {
        _directoryCount = chapters.length;
        return ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _choiceChip('All', selectedChapterId == null, () {
              setState(() {
                selectedChapterId = null;
                selectedChapter = null;
              });
              _applyDirectoryFilters();
            }),
            ...chapters.map(
              (chapter) => _choiceChip(
                chapter.name ?? chapter.shortCode ?? 'Chapter',
                selectedChapterId == chapter.id,
                () {
                  setState(() {
                    selectedChapterId = chapter.id;
                    selectedChapter = chapter.name;
                  });
                  _applyDirectoryFilters();
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _categoryChips() {
    final categories = ref.watch(businessCategoryNotifierProvider);
    _directoryCount = categories.length;
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _choiceChip('All', selectedCategoryId == null, () {
          setState(() {
            selectedCategoryId = null;
            selectedCategoryName = null;
          });
          _applyDirectoryFilters();
        }),
        ...categories.map(
          (category) => _choiceChip(
            category.name,
            selectedCategoryId == category.id,
            () {
              setState(() {
                selectedCategoryId = category.id;
                selectedCategoryName = category.name;
              });
              _applyDirectoryFilters();
            },
          ),
        ),
      ],
    );
  }

  Widget _districtChips() {
    final asyncDistricts = ref.watch(fetchDistrictsProvider);
    return asyncDistricts.when(
      data: (districts) {
        _directoryCount = districts.length;
        return ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _choiceChip('All', selectedDistrictId == null, () {
              setState(() {
                selectedDistrictId = null;
                selectedDistrictName = null;
              });
              _applyDirectoryFilters();
            }),
            ...districts.map(
              (district) => _choiceChip(
                district.name,
                selectedDistrictId == district.id,
                () {
                  setState(() {
                    selectedDistrictId = district.id;
                    selectedDistrictName = district.name;
                  });
                  _applyDirectoryFilters();
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _memberCard({
    required UserModel user,
    required VoidCallback onOpen,
    required VoidCallback onChat,
  }) {
    final meta = memberCompanyMeta(user);
    final chapter = memberChapterLabel(user);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Material(
        color: Colors.white,
        elevation: 0.6,
        shadowColor: const Color(0x14000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFEEEEF2)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Image.network(
                      user.image ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => SvgPicture.asset(
                        'assets/svg/icons/dummy_person_small.svg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: kCommunityText,
                        ),
                      ),
                      if (meta.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF8B939E),
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
                            fontSize: 12.5,
                            color: kCommunityMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onChat,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      size: 18,
                      color: Color(0xFF9AA1AB),
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

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _tagController.dispose();
    _debounce?.cancel();
    _searchFocus.dispose();
    super.dispose();
  }
}

enum _MemberFilterKind { chapter, category, district }

class _FilterChoice {
  final String id;
  final String label;

  const _FilterChoice({required this.id, required this.label});
}

class _FilterLabel extends StatelessWidget {
  final String text;

  const _FilterLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: kFamilyName,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF12141A),
        height: 1.2,
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final String? value;
  final VoidCallback onTap;

  const _FilterField({
    required this.icon,
    required this.hint,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.trim().isNotEmpty;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE6E6E6)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(icon, color: kPrimaryColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasValue ? value! : hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: kFamilyName,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: hasValue
                          ? const Color(0xFF12141A)
                          : const Color(0xFFA0A5AD),
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF8B9098),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberFilterPicker extends ConsumerStatefulWidget {
  final String title;
  final String? selectedId;
  final _MemberFilterKind kind;

  const _MemberFilterPicker({
    required this.title,
    required this.selectedId,
    required this.kind,
  });

  @override
  ConsumerState<_MemberFilterPicker> createState() =>
      _MemberFilterPickerState();
}

class _MemberFilterPickerState extends ConsumerState<_MemberFilterPicker> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.62,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFB2B5BE),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontFamily: kFamilyName,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF12141A),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value.trim()),
                style: const TextStyle(
                  fontFamily: kFamilyName,
                  fontSize: 14,
                  color: Color(0xFF12141A),
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search',
                  hintStyle: const TextStyle(
                    fontFamily: kFamilyName,
                    color: Color(0xFFA0A5AD),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFB0B6BE),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _options()),
          ],
        ),
      ),
    );
  }

  Widget _options() {
    switch (widget.kind) {
      case _MemberFilterKind.chapter:
        final asyncChapters = ref.watch(fetchChaptersProvider);
        return asyncChapters.when(
          data: (chapters) {
            final options = chapters
                .where((chapter) => (chapter.id ?? '').isNotEmpty)
                .map(
                  (chapter) => _FilterChoice(
                    id: chapter.id!,
                    label: (chapter.name ?? chapter.shortCode ?? '').trim(),
                  ),
                )
                .where((option) => option.label.isNotEmpty)
                .toList();
            return _optionList(options);
          },
          loading: () => const Center(child: LoadingAnimation()),
          error: (_, __) => const _PickerMessage('Unable to load chapters'),
        );
      case _MemberFilterKind.category:
        final categories = ref.watch(businessCategoryNotifierProvider);
        final loading =
            ref.read(businessCategoryNotifierProvider.notifier).isLoading;
        if (categories.isEmpty && loading) {
          return const Center(child: LoadingAnimation());
        }
        final options = categories
            .where((category) => category.id.isNotEmpty)
            .map(
              (category) => _FilterChoice(
                id: category.id,
                label: category.name.trim(),
              ),
            )
            .where((option) => option.label.isNotEmpty)
            .toList();
        return _optionList(options, emptyLabel: 'No categories found');
      case _MemberFilterKind.district:
        final asyncDistricts = ref.watch(fetchDistrictsProvider);
        return asyncDistricts.when(
          data: (districts) {
            final options = districts
                .where((district) => district.id.isNotEmpty)
                .map(
                  (district) => _FilterChoice(
                    id: district.id,
                    label: district.name.trim(),
                  ),
                )
                .where((option) => option.label.isNotEmpty)
                .toList();
            return _optionList(options, emptyLabel: 'No districts found');
          },
          loading: () => const Center(child: LoadingAnimation()),
          error: (_, __) => const _PickerMessage('Unable to load districts'),
        );
    }
  }

  Widget _optionList(List<_FilterChoice> options, {String? emptyLabel}) {
    final query = _query.toLowerCase();
    final visible = query.isEmpty
        ? options
        : options
            .where((option) => option.label.toLowerCase().contains(query))
            .toList();
    if (visible.isEmpty) {
      return _PickerMessage(emptyLabel ?? 'No results found');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      itemCount: visible.length,
      itemBuilder: (context, index) {
        final option = visible[index];
        final selected = option.id == widget.selectedId;
        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            option.label,
            style: TextStyle(
              fontFamily: kFamilyName,
              fontSize: 15,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? kPrimaryColor : const Color(0xFF12141A),
            ),
          ),
          trailing: selected
              ? const Icon(Icons.check, color: kPrimaryColor, size: 20)
              : null,
          onTap: () => Navigator.pop(context, option),
        );
      },
    );
  }
}

class _PickerMessage extends StatelessWidget {
  final String text;

  const _PickerMessage(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: kFamilyName,
            fontSize: 14,
            color: Color(0xFF8B93A0),
          ),
        ),
      ),
    );
  }
}
