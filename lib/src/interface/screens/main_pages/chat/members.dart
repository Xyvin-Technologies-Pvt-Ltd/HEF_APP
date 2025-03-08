import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/chat_api/chat_api.dart';
import 'package:hef/src/data/api_routes/levels_api/levels_api.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/chat_model.dart';
import 'package:hef/src/data/notifiers/people_notifier.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';

import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/screens/main_pages/chat/chat_screen.dart';
import 'package:hef/src/interface/screens/main_pages/profile/profile_preview.dart';
import 'package:shimmer/shimmer.dart';

import 'dart:async';

class MembersPage extends ConsumerStatefulWidget {
  const MembersPage({super.key});

  @override
  ConsumerState<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends ConsumerState<MembersPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocus = FocusNode();
  Timer? _debounce;
  String? selectedDistrictId;
  String? selectedDistrictName;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchInitialUsers();
  }

  Future<void> _fetchInitialUsers() async {
    await ref.read(peopleNotifierProvider.notifier).fetchMoreUsers();
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
      ref.read(peopleNotifierProvider.notifier).searchUsers(query);
    });
  }

  void _onSearchSubmitted(String query) {
    ref.read(peopleNotifierProvider.notifier).searchUsers(query);
  }

  void _showFilterBottomSheet() {
    String? tempDistrictId = selectedDistrictId;
    String? tempDistrictName = selectedDistrictName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Members',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (tempDistrictName != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            tempDistrictId = null;
                            tempDistrictName = null;
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red[400],
                        ),
                        child: const Text('Reset'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),

                // Filter Options
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            childrenPadding: EdgeInsets.zero,
                            title: Row(
                              children: [
                                const Icon(Icons.location_on_outlined),
                                const SizedBox(width: 8),
                                const Text(
                                  'District',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (tempDistrictName != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '1 selected',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            children: [
                              Consumer(
                                builder: (context, ref, child) {
                                  final asyncDistricts =
                                      ref.watch(fetchDistrictsProvider);
                                  return asyncDistricts.when(
                                    data: (districts) {
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: districts.length,
                                        itemBuilder: (context, index) {
                                          final district = districts[index];
                                          return ListTile(
                                            dense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12),
                                            title: Text(
                                              district.name,
                                              style: TextStyle(
                                                color: tempDistrictId ==
                                                        district.id
                                                    ? Colors.blue[700]
                                                    : null,
                                              ),
                                            ),
                                            trailing:
                                                tempDistrictId == district.id
                                                    ? Icon(Icons.check_circle,
                                                        color: Colors.blue[700])
                                                    : null,
                                            onTap: () {
                                              setState(() {
                                                tempDistrictId = district.id;
                                                tempDistrictName =
                                                    district.name;
                                              });
                                            },
                                          );
                                        },
                                      );
                                    },
                                    loading: () =>
                                        const Center(child: LoadingAnimation()),
                                    error: (error, stackTrace) =>
                                        const SizedBox(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Apply Button
                const SizedBox(height: 16),
                SizedBox(
                    width: double.infinity,
                    child: customButton(
                      label: 'Apply',
                      onPressed: () {
                        setState(() {
                          selectedDistrictId = tempDistrictId;
                          selectedDistrictName = tempDistrictName;
                        });
                        ref
                            .read(peopleNotifierProvider.notifier)
                            .setDistrict(tempDistrictId);
                        Navigator.pop(context);
                      },
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(peopleNotifierProvider);
    final isLoading = ref.read(peopleNotifierProvider.notifier).isLoading;
    final asyncChats = ref.watch(fetchChatThreadProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Search Bar with Filter
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocus,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Search Members',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 216, 211, 211),
                              ),
                            ),
                          ),
                          onChanged: _onSearchChanged,
                          onSubmitted: _onSearchSubmitted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 216, 211, 211),
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.filter_list,
                            color: selectedDistrictName != null
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          onPressed: _showFilterBottomSheet,
                        ),
                      ),
                    ],
                  ),
                  if (selectedDistrictName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          const Text('Filtered by: '),
                          Chip(
                            label: Text(selectedDistrictName!),
                            onDeleted: () {
                              setState(() {
                                selectedDistrictId = null;
                                selectedDistrictName = null;
                              });
                              ref
                                  .read(peopleNotifierProvider.notifier)
                                  .setDistrict(null);
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Display User List or No Data Message
            if (users.isNotEmpty)
              ListView.builder(
                shrinkWrap: true, // Prevents infinite height
                physics:
                    const NeverScrollableScrollPhysics(), // Disable scrolling inside Column
                itemCount: users.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == users.length) {
                    return Center(child: LoadingAnimation());
                  }
                  final user = users[index];
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

                      return Column(
                        children: [
                          ListTile(
                            leading: SizedBox(
                              height: 40,
                              width: 40,
                              child: ClipOval(
                                child: Image.network(
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    );
                                  },
                                  user.image ?? '',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                        'assets/pngs/dummy_person_small.png');
                                  },
                                ),
                              ),
                            ),
                            title: Text(
                              '${user.name ?? ''}',
                            ),
                            subtitle: (user.company?.isNotEmpty ?? false)
                                ? Text(user.company![0].designation ?? '')
                                : null,
                            trailing: IconButton(
                              icon: Icon(Icons.chat_bubble_outline),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => IndividualPage(
                                      receiver: receiver!,
                                      sender: sender!,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const Divider(
                            thickness: 1,
                            color: Color.fromARGB(255, 227, 221, 221),
                            height: 1,
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (error, stackTrace) => Text('Error loading chats'),
                  );

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfilePreview(user: user),
                        ),
                      );
                    },
                    child: asyncUserChat,
                  );
                },
              )
            else
              const Column(
                children: [
                  SizedBox(height: 100),
                  Text(
                    'No Members Found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    _searchFocus.dispose();
    super.dispose();
  }
}
