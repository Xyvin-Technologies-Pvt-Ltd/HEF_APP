import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hef/src/data/api_routes/chat_api/chat_api.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/models/chat_model.dart';
import 'package:hef/src/data/models/msg_model.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:hef/src/data/services/audio_upload.dart';
import 'package:hef/src/data/services/voice_recorder.dart';
import 'package:hef/src/interface/components/Dialogs/blockPersonDialog.dart';
import 'package:hef/src/interface/components/Dialogs/report_dialog.dart';
import 'package:hef/src/interface/components/common/own_message_card.dart';
import 'package:hef/src/interface/components/common/reply_card.dart';
import 'package:hef/src/interface/screens/main_pages/profile/profile_preview.dart';
import 'package:hef/src/interface/screens/main_pages/chat/voice_recorder_widget.dart';
import 'package:intl/intl.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io';
import 'package:hef/src/data/services/image_upload.dart';

class IndividualPage extends ConsumerStatefulWidget {
  IndividualPage({required this.receiver, required this.sender, super.key});
  final Participant receiver;
  final Participant sender;
  @override
  _IndividualPageState createState() => _IndividualPageState();
}

class _IndividualPageState extends ConsumerState<IndividualPage> {
  bool isBlocked = false;
  bool show = false;
  bool _showEmojiKeyboard = false;
  bool _isRecording = false;
  bool _isLocked = false;
  Duration _recordDuration = Duration.zero;

  FocusNode focusNode = FocusNode();
  List<MessageModel> messages = [];
  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final VoiceRecorder _voiceRecorder = VoiceRecorder();

  File? _recordedFile;

  @override
  void initState() {
    super.initState();
    // Initialize recorder
    _voiceRecorder.init();
    // Listen to recording progress
    _voiceRecorder.onProgress = (duration) {
      setState(() {
        _recordDuration = duration;
      });
    };
    _voiceRecorder.onStop = (file) {
      _recordedFile = file;
    };

    getMessageHistory();
  }

  void getMessageHistory() async {
    final messagesette =
        await ChatApiService.getChatBetweenUsers(widget.receiver.id!);
    if (mounted) {
      setState(() {
        messages.addAll(messagesette);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBlockStatus();
  }

  Future<void> _loadBlockStatus() async {
    final asyncUser = ref.watch(userProvider);
    asyncUser.whenData(
      (user) {
        setState(() {
          if (user.blockedUsers != null) {
            isBlocked = user.blockedUsers!
                .any((blockedUser) => blockedUser == widget.receiver.id);
          }
        });
      },
    );
  }

  @override
  void dispose() {
    focusNode.unfocus();
    _controller.dispose();
    _voiceRecorder.dispose();
    _scrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  // void sendMessage() {
  //   if (_controller.text.isNotEmpty && mounted) {
  //     ChatApiService.sendChatMessage(
  //       Id: widget.receiver.id!,
  //       content: _controller.text,
  //       type: 'text',
  //     );
  //     setMessage("sent", _controller.text, widget.sender.id!, msgType: "text");
  //     _controller.clear();
  //   }
  // }
  void sendMessage({List<Attachment>? attachments}) {
    final text = _controller.text;
    if ((text.isNotEmpty || (attachments != null && attachments.isNotEmpty)) &&
        mounted) {
      ChatApiService.sendChatMessage(
        Id: widget.receiver.id!,
        content: text.isNotEmpty ? text : null,
        attachments: attachments, // pass attachments
        type: attachments != null && attachments.isNotEmpty
            ? attachments.first.type
            : 'text',
      );

      setMessage(
        "sent",
        text,
        widget.sender.id!,
        msgType: attachments != null && attachments.isNotEmpty
            ? attachments.first.type
            : "text",
        attachments: attachments,
      );

      _controller.clear();
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);

    if (photo != null) {
      try {
        String imageUrl = await imageUpload(photo.path);

        final attachment = Attachment(url: imageUrl, type: 'image');

        sendMessage(attachments: [attachment]); // Use updated sendMessage
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  Future<void> _takePicture() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      try {
        String imageUrl = await imageUpload(photo.path);

        final attachment = Attachment(url: imageUrl, type: 'image');

        sendMessage(attachments: [attachment]);
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      try {
        String fileUrl = await imageUpload(file.path); // reuse uploader

        final attachment = Attachment(url: fileUrl, type: 'file');

        sendMessage(attachments: [attachment]);
      } catch (e) {
        print("Error uploading document: $e");
      }
    }
  }

  // Emoji picker functionality
  void _onEmojiSelected(Category? category, Emoji emoji) {
    setState(() {
      _controller.text += emoji.emoji;
    });
  }

// //emoji
//   void _toggleEmojiPicker() {
//     setState(() {
//       _showEmojiPicker = !_showEmojiPicker;
//     });

//     // Hide keyboard when emoji picker is shown
//     if (_showEmojiPicker) {
//       focusNode.unfocus();
//     }
//   }

  Widget _buildEmojiPicker() {
    if (!_showEmojiKeyboard) return SizedBox.shrink();

    return Expanded(
      child: EmojiPicker(
        onEmojiSelected: _onEmojiSelected,
        config: const Config(
          categoryViewConfig: CategoryViewConfig(
            backgroundColor: kWhite,
            dividerColor: kPrimaryLightColor,
            indicatorColor: kPrimaryColor,
            iconColor: kGrey,
            iconColorSelected: kPrimaryColor,
            backspaceColor: kPrimaryColor,
            categoryIcons: CategoryIcons(),
            tabIndicatorAnimDuration: Duration(milliseconds: 300),
          ),
          skinToneConfig: SkinToneConfig(
            dialogBackgroundColor: kWhite,
            indicatorColor: kWhite,
          ),
          height: 200,
          bottomActionBarConfig: BottomActionBarConfig(
              backgroundColor: kPrimaryLightColor, buttonColor: kPrimaryColor),
          checkPlatformCompatibility: true,
        ),
      ),
    );
  }

  void setMessage(String statusType, String message, String fromId,
      {String msgType = 'text', List<Attachment>? attachments}) {
    final messageModel = MessageModel(
      from: fromId,
      status: statusType,
      content: message,
      createdAt: DateTime.now(),
      attachments: attachments ?? [],
    );

    setState(() {
      messages.add(messageModel);
    });
  }

  @override
  Widget build(BuildContext context) {
    final messageStream = ref.watch(messageStreamProvider);

    messageStream.whenData((newMessage) {
      bool messageExists = messages.any((message) =>
          message.createdAt == newMessage.createdAt &&
          message.content == newMessage.content);

      if (!messageExists) {
        setState(() {
          messages.add(newMessage);
        });
      }
    });

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: AppBar(
                  actions: [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert), // The three-dot icon
                      onSelected: (value) {
                        if (value == 'report') {
                          showReportPersonDialog(
                            context: context,
                            onReportStatusChanged: () {},
                            reportType: 'User',
                            reportedItemId: widget.receiver.id ?? '',
                          );
                        } else if (value == 'block') {
                          showBlockPersonDialog(
                            context: context,
                            userId: widget.receiver.id ?? '',
                            onBlockStatusChanged: () {
                              Future.delayed(const Duration(seconds: 1), () {
                                setState(() {
                                  isBlocked = !isBlocked;
                                });
                              });
                            },
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'report',
                          child: Row(
                            children: [
                              Icon(Icons.report, color: kPrimaryColor),
                              SizedBox(width: 8),
                              Text('Report'),
                            ],
                          ),
                        ),
                        // Divider for visual separation
                        const PopupMenuDivider(height: 1),
                        PopupMenuItem(
                          value: 'block',
                          child: Row(
                            children: [
                              Icon(Icons.block),
                              SizedBox(width: 8),
                              isBlocked ? Text('Unblock') : Text('Block'),
                            ],
                          ),
                        ),
                      ],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            12), // Border radius for the menu
                      ),
                      color: Colors
                          .white, // Optional: set background color for the menu
                      offset: const Offset(
                          0, 40), // Optional: adjust the position of the menu
                    )
                  ],
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
                          Icons.arrow_back_ios,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ClipOval(
                        child: Container(
                          width: 30,
                          height: 30,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          child: Image.network(
                            widget.receiver.image ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return SvgPicture.asset(
                                  'assets/svg/icons/dummy_person_small.svg');
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Consumer(
                    builder: (context, ref, child) {
                      final asyncUser = ref.watch(
                          fetchUserDetailsProvider(widget.receiver.id ?? ''));
                      return asyncUser.when(
                        data: (user) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => ProfilePreview(
                                    user: user,
                                  ),
                                  transitionDuration:
                                      const Duration(milliseconds: 500),
                                  transitionsBuilder: (_, a, __, c) =>
                                      FadeTransition(opacity: a, child: c),
                                ),
                              );
                            },
                            child: Text(
                              '${widget.receiver.name ?? ''}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          );
                        },
                        loading: () => Text(
                          '${widget.receiver.name ?? ''}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        error: (error, stackTrace) {
                          // Handle error state
                          return const Center(
                            child: Text(
                                'Something went wrong please try again later'),
                          );
                        },
                      );
                    },
                  ),
                )),
            body: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFFBFAF8),
                    Color(0xFFE8D5B5),
                  ],
                  center: Alignment.center,
                  radius: 0.8,
                ),
              ),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: PopScope(
                child: Column(
                  children: [
                    Expanded(
                      child: messages.isNotEmpty
                          ? ListView.builder(
                              reverse: true,
                              controller: _scrollController,
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message =
                                    messages[messages.length - 1 - index];

                                if (message.from == widget.sender.id) {
                                  return OwnMessageCard(
                                    product: message.product,
                                    requirement: message.feed,
                                    status: message.status!,
                                    message: message.content ?? '',
                                    // 🔹 UPDATE: Determine type from attachments if available
                                    type:
                                        message.attachments?.isNotEmpty == true
                                            ? message.attachments!.first.type
                                            : 'text',
                                    // 🔹 UPDATE: Pass fileUrl from first attachment
                                    fileUrl:
                                        message.attachments?.isNotEmpty == true
                                            ? message.attachments!.first.url
                                            : null,
                                    // 🔹 UPDATE: Pass the attachments list
                                    attachments: message.attachments,
                                    time: DateFormat('h:mm a').format(
                                      DateTime.parse(
                                              message.createdAt.toString())
                                          .toLocal(),
                                    ),
                                  );
                                } else {
                                  return GestureDetector(
                                    onLongPress: () {
                                      showReportPersonDialog(
                                          reportedItemId: message.id ?? '',
                                          context: context,
                                          onReportStatusChanged: () {},
                                          reportType: 'Message');
                                    },
                                    child: ReplyCard(
                                      business: message.feed,
                                      message: message.content ?? '',
                                      attachments: message.attachments,
                                      time: DateFormat('h:mm a').format(
                                        DateTime.parse(
                                                message.createdAt.toString())
                                            .toLocal(),
                                      ),
                                    ),
                                  );
                                }
                              },
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                  child: Image.asset(
                                      'assets/pngs/startConversation.png')),
                            ),
                    ),
                    isBlocked
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                            ),
                            decoration: const BoxDecoration(
                              color: kPrimaryColor,
                              boxShadow: [
                                BoxShadow(
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
                            child: Stack(children: [
                              Container(
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
                                            color: Color.fromARGB(
                                                255, 220, 215, 215),
                                            width: 0.5,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 5.0),
                                          child: Container(
                                            constraints: const BoxConstraints(
                                              maxHeight:
                                                  150, // Limit the height
                                            ),
                                            child: Scrollbar(
                                              thumbVisibility: true,
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.vertical,
                                                reverse:
                                                    true, // Start from bottom
                                                child: Row(
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(_showEmojiKeyboard
                                                          ? Icons.keyboard
                                                          : Icons
                                                              .emoji_emotions_outlined),
                                                      onPressed: () {
                                                        setState(() {
                                                          _showEmojiKeyboard =
                                                              !_showEmojiKeyboard;
                                                        });

                                                        if (_showEmojiKeyboard) {
                                                          // Hide system keyboard when showing emoji keyboard
                                                          FocusScope.of(context)
                                                              .unfocus();
                                                        } else {
                                                          // Show system keyboard when emoji keyboard is hidden
                                                          FocusScope.of(context)
                                                              .requestFocus(
                                                                  focusNode);
                                                        }
                                                      },
                                                    ),
                                                    Expanded(
                                                      child: TextField(
                                                        controller: _controller,
                                                        focusNode: focusNode,
                                                        keyboardType:
                                                            TextInputType
                                                                .multiline,
                                                        maxLines:
                                                            null, // Allows for unlimited lines
                                                        minLines:
                                                            1, // Starts with a single line
                                                        decoration:
                                                            const InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          hintText:
                                                              "Type a message",
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          10),
                                                        ),
                                                        onChanged: (text) {
                                                          setState(
                                                              () {}); // COMMAND: rebuild to toggle mic/send icon
                                                        },
                                                      ),
                                                    ),
                                                    // Attachment button
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.attach_file,
                                                          color: Colors.grey),
                                                      onPressed: _pickDocument,
                                                    ),
                                                    // Camera button
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.camera_alt,
                                                          color: Colors.grey),
                                                      onPressed: _takePicture,
                                                    ),
                                                  ],
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
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: IconButton(
                                          icon: _controller.text.isEmpty
                                              ? Icon(Icons.mic,
                                                  color: Colors
                                                      .white) // COMMAND: mic icon when text empty
                                              : Icon(Icons.send,
                                                  color: Colors
                                                      .white), // COMMAND: send icon when typing
                                          onPressed: () async {
                                            if (_controller.text.isEmpty) {
                                              if (!_isRecording) {
                                                await _voiceRecorder.init();
                                                await _voiceRecorder
                                                    .startRecording();
                                                setState(() {
                                                  _isRecording = true;
                                                });
                                              } else {
                                                //stop recording
                                                File recordedFile =
                                                    await _voiceRecorder
                                                        .stopRecording();
                                                setState(() {
                                                  _isRecording = false;
                                                  _recordedFile = recordedFile;
                                                });
                                                String audioUrl =
                                                    await audioUpload(
                                                        _recordedFile as String);
                                                sendMessage(
                                                  attachments: [
                                                    Attachment(
                                                        url: audioUrl,
                                                        type: 'voice')
                                                  ],
                                                );
                                              }
                                            } else {
                                              // COMMAND: send text message
                                              sendMessage();
                                              _controller.clear();
                                              setState(
                                                  () {}); // refresh to toggle back to mic icon
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // COMMAND: VoiceRecorder overlay
                              if (_isRecording)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: VoiceRecorderWidget(
                                    isRecording: _isRecording,
                                    isLocked: _isLocked,
                                    duration: _recordDuration,
                                    onCancel: () async {
                                      await _voiceRecorder.cancel();
                                      setState(() {
                                        _isRecording = false;
                                        _recordDuration = Duration.zero;
                                      });
                                    },
                                    onSend: () async {
                                      // final file = _recordedFile;
                                      // if (file != null) {
                                      //   final url =
                                      //       await audioUpload(file.path);

                                      //   // Send as attachment
                                      //   final attachment =
                                      //       Attachment(url: url, type: 'voice');
                                      //   sendMessage(attachments: [attachment]);
                                      // }
                                      // setState(() {
                                      //   _isRecording = false;
                                      //   _recordDuration = Duration.zero;
                                      //   _recordedFile = null;
                                      // });

                                      File recordedFile =
                                                    await _voiceRecorder
                                                        .stopRecording();
                                                setState(() {
                                                  _isRecording = false;
                                                  _recordedFile = recordedFile;
                                                });
                                                String audioUrl =
                                                    await audioUpload(
                                                        _recordedFile as String);
                                                sendMessage(
                                                  attachments: [
                                                    Attachment(
                                                        url: audioUrl,
                                                        type: 'voice')
                                                  ],
                                                );
                                    },
                                    onLock: () =>
                                        setState(() => _isLocked = true),
                                    onUnlock: () =>
                                        setState(() => _isLocked = false),
                                  ),
                                ),
                            ]),
                          ),
                    // Emoji picker
                    _buildEmojiPicker(),
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
      ),
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
