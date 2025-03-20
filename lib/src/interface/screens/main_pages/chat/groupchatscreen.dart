import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/chat_api/chat_api.dart';
import 'package:hef/src/data/api_routes/group_chat_api/group_chat_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/models/chat_model.dart';
import 'package:hef/src/data/models/group_chat_model.dart';
import 'package:hef/src/data/models/msg_model.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:hef/src/interface/components/Dialogs/report_dialog.dart';
import 'package:hef/src/interface/components/common/groupchat_own_message_card.dart';
import 'package:hef/src/interface/components/common/groupchat_reply_msg_card.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/screens/main_pages/chat/group_info.dart';
import 'package:intl/intl.dart';

class Groupchatscreen extends ConsumerStatefulWidget {
  Groupchatscreen({required this.group, required this.sender, super.key});
  final Participant group;
  final Participant sender;
  @override
  _IndividualPageState createState() => _IndividualPageState();
}

class _IndividualPageState extends ConsumerState<Groupchatscreen> {
  bool isBlocked = false;
  bool show = false;
  FocusNode focusNode = FocusNode();
  List<GroupChatModel> messages = [];
  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getMessageHistory();
  }

  void getMessageHistory() async {
    final messagesette = await getGroupChatMessages(groupId: widget.group.id!);
    if (mounted) {
      setState(() {
        messages.addAll(messagesette);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBlockStatus(); // Now safe to call
  }

  Future<void> _loadBlockStatus() async {
    final asyncUser = ref.watch(userProvider);
    asyncUser.whenData(
      (user) {
        setState(() {
          if (user.blockedUsers != null) {
            isBlocked = user.blockedUsers!
                .any((blockedUser) => blockedUser == widget.group.id);
          }
        });
      },
    );
  }

  @override
  void dispose() {
    focusNode.unfocus();
    _controller.dispose();
    _scrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void sendMessage() {
    if (_controller.text.isNotEmpty && mounted) {
      sendChatMessage(
        isGroup: true,
        Id: widget.group.id!,
        content: _controller.text,
      );
      setMessage("sent", _controller.text, widget.sender.id!);
      _controller.clear();
    }
  }

  void setMessage(String type, String message, String fromId) {
    final messageModel = GroupChatModel(
      content: message,
      from: GroupChatUserModel(id: fromId),
      status: type,
      createdAt: DateTime.now(),
    );

    MessageModel(
      from: fromId,
      status: type,
      content: message,
      createdAt: DateTime.now(),
    );

    setState(() {
      messages.add(messageModel);
    });
  }
@override
Widget build(BuildContext context) {
  final groupMessageStream = ref.watch(groupMessageStreamProvider);

  groupMessageStream.whenData((newMessage) {
    bool messageExists = messages.any((message) =>
        message.createdAt == newMessage.createdAt &&
        message.content == newMessage.content);

    if (!messageExists) {
      setState(() {
        messages.add(newMessage);
      });
    }
  });


    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFFCFCFC),
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: AppBar(
                elevation: 1,
                shadowColor: Colors.white,
                backgroundColor: Colors.white,
                leadingWidth: 90,
                titleSpacing: 0,
                leading: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ClipOval(
                      child: Container(
                        width: 36,
                        height: 36,
                        color: Colors.red,
                        child: Image.network(
                          widget.group.image ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.groups_2,
                              color: Colors.white,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                title: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GroupInfoPage(
                              groupId: widget.group.id ?? '',
                              groupName: '${widget.group.name ?? ''}')),
                    );
                  },
                  child: Text(
                    '${widget.group.name ?? ''}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                actions: [
                  IconButton(
                      icon: const Icon(Icons.report),
                      onPressed: () {
                        showReportPersonDialog(
                            context: context,
                            onReportStatusChanged: () {},
                            reportType: 'User',
                            reportedItemId: widget.group.id ?? '');
                      }),
                  // IconButton(
                  //     icon: const Icon(Icons.block),
                  //     onPressed: () {
                  //       showBlockPersonDialog(
                  //           context: context,
                  //           userId: widget.group.id ?? '',
                  //           onBlockStatusChanged: () {
                  //             Future.delayed(Duration(seconds: 1));
                  //             setState(() {
                  //               if (isBlocked) {
                  //                 isBlocked = false;
                  //               } else {
                  //                 isBlocked = true;
                  //               }
                  //             });
                  //           });
                  //     }),
                ],
              )),
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: PopScope(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      reverse: true,
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[messages.length -
                            1 -
                            index]; // Reverse the index to get the latest message first
                        if (message.from?.id == widget.sender.id) {
                          return Consumer(
                            builder: (context, ref, child) {
                              final asyncUser = ref.watch(userProvider);
                              return asyncUser.when(
                                data: (user) {
                                  return GroupchatOwnMessageCard(
                                    username: '${user.name ?? ''}',
                                    status: message.status!,
                                    message: message.content ?? '',
                                    time: DateFormat('h:mm a').format(
                                      DateTime.parse(
                                              message.createdAt.toString())
                                          .toLocal(),
                                    ),
                                  );
                                },
                                loading: () =>
                                    Center(child: LoadingAnimation()),
                                error: (error, stackTrace) {
                                  return Text('Something went wrong');
                                },
                              );
                            },
                          );
                        } else {
                          return GestureDetector(
                              onLongPress: () {
                                showReportPersonDialog(
                                    reportedItemId: message.id ?? '',
                                    context: context,
                                    onReportStatusChanged: () {
                                      setState(() {
                                        if (isBlocked) {
                                          isBlocked = false;
                                        } else {
                                          isBlocked = true;
                                        }
                                      });
                                    },
                                    reportType: 'Message');
                              },
                              child: GroupchatReplyMsgCard(
                                username: '${message.from?.name ?? ''}',
                                message: message.content ?? '',
                                time: DateFormat('h:mm a').format(
                                  DateTime.parse(message.createdAt.toString())
                                      .toLocal(),
                                ),
                              ));
                        }
                      },
                    ),
                  ),
                  isBlocked
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFE30613),
                            boxShadow: [
                              const BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(4, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'This user is blocked',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.5,
                                shadows: [
                                  // Shadow(
                                  //   color: Colors.black45,
                                  //   blurRadius: 5,
                                  //   offset: Offset(2, 2),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 12.0),
                            color: kScaffoldColor,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Card(
                                    elevation: 1,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 220, 215, 215),
                                        width: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 5.0),
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          maxHeight: 150, // Limit the height
                                        ),
                                        child: Scrollbar(
                                          thumbVisibility: true,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            reverse: true, // Start from bottom
                                            child: TextField(
                                              controller: _controller,
                                              focusNode: focusNode,
                                              keyboardType:
                                                  TextInputType.multiline,
                                              maxLines:
                                                  null, // Allows for unlimited lines
                                              minLines:
                                                  1, // Starts with a single line
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                hintText: "Type a message",
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 10),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 2,
                                    left: 2,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: kPrimaryColor,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.send,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        sendMessage();
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                ],
              ),
              onPopInvoked: (didPop) {
                if (didPop) {
                  if (show) {
                    setState(() {
                      show = false;
                    });
                  } else {
                    focusNode.unfocus();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    });
                  }
                  ref.invalidate(fetchChatThreadProvider);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 278,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(
                      Icons.insert_drive_file, Colors.indigo, "Document"),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.camera_alt, Colors.pink, "Camera"),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.insert_photo, Colors.purple, "Gallery"),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(Icons.headset, Colors.orange, "Audio"),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.location_pin, Colors.teal, "Location"),
                  const SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.person, Colors.blue, "Contact"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(IconData icons, Color color, String text) {
    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(
              icons,
              size: 29,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }
}
