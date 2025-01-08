import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hef/src/data/api_routes/chat_api/chat_api.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/chat_model.dart';
import 'package:hef/src/data/notifiers/people_notifier.dart';

import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/screens/main_pages/chat/chat_screen.dart';
import 'package:hef/src/interface/screens/main_pages/profile/profile_preview.dart';
import 'package:shimmer/shimmer.dart';

class MembersPage extends ConsumerStatefulWidget {
  const MembersPage({super.key});

  @override
  ConsumerState<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends ConsumerState<MembersPage> {
  final ScrollController _scrollController = ScrollController();

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

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(peopleNotifierProvider);
    final isLoading = ref.read(peopleNotifierProvider.notifier).isLoading;
    final asyncChats = ref.watch(fetchChatThreadProvider);
    return Scaffold(
        backgroundColor: Colors.white,
        body: users.isEmpty
            ? Center(child: LoadingAnimation()) // Show loader when no data
            : asyncChats.when(
                data: (chats) {
                  log('im inside chat');
                  return ListView.builder(
                      controller: _scrollController,
                      itemCount: users.length +
                          (isLoading
                              ? 1
                              : 0), // Add 1 to show the loading indicator
                      itemBuilder: (context, index) {
                        if (index == users.length) {
                          // This is the loading indicator at the end of the list
                          return Center(
                            child:
                                LoadingAnimation(), // Show loading indicator when fetching more users
                          );
                        }

                        // Regular user item
                        var chatForUser = chats.firstWhere(
                          (chat) =>
                              chat.participants?.any((participant) =>
                                  participant.id == users[index].uid) ??
                              false,
                          orElse: () => ChatModel(
                            participants: [
                              Participant(
                                id: users[index].uid,
                                name: users[index].name,
                                image: users[index].image,
                              ),
                              Participant(
                                  id: id), // Replace with current user if needed
                            ],
                          ),
                        );

                        var receiver = chatForUser.participants?.firstWhere(
                          (participant) => participant.id != id,
                          orElse: () => Participant(
                            id: users[index].uid,
                            name: users[index].name,
                            image: users[index].image,
                          ),
                        );

                        var sender = chatForUser.participants?.firstWhere(
                          (participant) => participant.id == id,
                          orElse: () => Participant(),
                        );

                        final user = users[index];

                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProfilePreview(user: user),
                                  ),
                                );
                              },
                              child: ListTile(
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
                                        // While the image is loading, show shimmer effect
                                        return Container(
                                          child: Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      user.image ?? '',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                  return SvgPicture.asset(
                                      'assets/svg/icons/dummy_person_small.svg');
                                },
                                    ),
                                  ),
                                ),
                                title: Text('${user.name ?? ''}'),
                                subtitle: user.company?.designation != null
                                    ? Text(user.company?.designation ?? '')
                                    : null,
                                trailing: IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.message,
                                    size: 17,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => IndividualPage(
                                        receiver: receiver!,
                                        sender: sender!,
                                      ),
                                    ));
                                  },
                                ),
                              ),
                            ),
                            Divider(
                                thickness: 1,
                                height: 1,
                                color: Colors.grey[300]), // Full-width divider
                          ],
                        );
                      });
                },
                loading: () => Center(child: LoadingAnimation()),
                error: (error, stackTrace) {
                  return Center(
                    child: Text("Failed to load members"),
                  );
                },
              ));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
