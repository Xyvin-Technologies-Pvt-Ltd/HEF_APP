import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/chat_api/chat_api.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/chat_model.dart';
import 'package:hef/src/data/notifiers/people_notifier.dart';

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
            // Search Bar
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
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
                                        'assets/icons/dummy_person_small.png');
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
