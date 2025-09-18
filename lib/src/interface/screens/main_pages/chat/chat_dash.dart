import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hef/src/data/api_routes/chat_api/chat_api.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/chat_model.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/screens/main_pages/chat/chat_screen.dart';
import 'package:shimmer/shimmer.dart';

class ChatDash extends ConsumerStatefulWidget {
  ChatDash({super.key});

  @override
  ConsumerState<ChatDash> createState() => _ChatDashState();
}

class _ChatDashState extends ConsumerState<ChatDash> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  String _searchQuery = "";

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
    });
  }

  void _onSearchSubmitted(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncChats = ref.watch(fetchChatThreadProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
         
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search Chats',
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
          ),

        
          Expanded(
            child: asyncChats.when(
              data: (chats) {
                // search filter for filtering chats
                final filteredChats = chats.where((chat) {
                  var receiver = chat.participants?.firstWhere(
                    (p) => p.id != id,
                    orElse: () => Participant(),
                  );
                  return receiver?.name
                          ?.toLowerCase()
                          .contains(_searchQuery) ??
                      false;
                }).toList();

                if (filteredChats.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Image.asset('assets/pngs/nochat.png'),
                        ),
                      ),
                      const Text('No chat yet!')
                    ],
                  );
                }

                return ListView.builder(
                  itemCount: filteredChats.length,
                  itemBuilder: (context, index) {
                    var chat = filteredChats[index];
                    var receiver = chat.participants?.firstWhere(
                      (p) => p.id != id,
                      orElse: () => Participant(),
                    );
                    var sender = chat.participants?.firstWhere(
                      (p) => p.id == id,
                      orElse: () => Participant(),
                    );

                    return Column(
                      children: [
                        ListTile(
                          leading: ClipOval(
                            child: Container(
                              width: 40,
                              height: 40,
                              color: Colors.white,
                              child: Image.network(
                                receiver?.image ?? '',
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
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
                                errorBuilder: (context, error, stackTrace) {
                                  return SvgPicture.asset(
                                      'assets/svg/icons/dummy_person_small.svg');
                                },
                              ),
                            ),
                          ),
                          title: Text('${receiver?.name ?? ''}'),
                          subtitle: Text(
                            chat.lastMessage?.content != null
                                ? (chat.lastMessage!.content!.length > 10
                                    ? '${chat.lastMessage?.content!.substring(0, 10)}...'
                                    : chat.lastMessage!.content!)
                                : '',
                          ),
                          trailing: chat.unreadCount?[sender?.id] != 0 &&
                                  chat.unreadCount?[sender!.id] != null
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${chat.unreadCount?[sender!.id]}',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => IndividualPage(
                                receiver: receiver!,
                                sender: sender!,
                              ),
                            ));
                          },
                        ),
                        Divider(
                          thickness: 1,
                          height: 1,
                          color: Colors.grey[350],
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: LoadingAnimation()),
              error: (error, stackTrace) => Center(child: Text('$error')),
            ),
          ),
        ],
      ),
    );
  }
}
