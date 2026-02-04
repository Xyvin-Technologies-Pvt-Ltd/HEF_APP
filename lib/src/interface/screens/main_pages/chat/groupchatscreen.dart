import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:hef/src/data/api_routes/chat_api/chat_api.dart';
import 'package:hef/src/data/api_routes/group_chat_api/group_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/chat_model.dart';
import 'package:hef/src/data/models/group_chat_model.dart';
import 'package:hef/src/data/models/msg_model.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:hef/src/data/services/audio_upload.dart';
import 'package:hef/src/data/services/image_upload.dart';
import 'package:hef/src/data/services/video_upload.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hef/src/data/services/voice_recorder.dart';
import 'package:hef/src/interface/components/Dialogs/report_dialog.dart';
import 'package:hef/src/interface/components/common/groupchat_own_message_card.dart';
import 'package:hef/src/interface/components/common/groupchat_reply_msg_card.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/screens/main_pages/chat/group_info.dart';
import 'package:hef/src/interface/screens/main_pages/chat/voice_recorder_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

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
  bool _showEmojiKeyboard = false;
  bool _isRecording = false;
  bool _isLocked = false;
  Duration _recordDuration = Duration.zero;

  FocusNode focusNode = FocusNode();
  List<GroupChatModel> messages = [];
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

    // Add focus listener to hide emoji picker when text field is focused
    focusNode.addListener(() {
      if (focusNode.hasFocus && _showEmojiKeyboard) {
        setState(() {
          _showEmojiKeyboard = false;
        });
      }
    });

    getMessageHistory();
  }

  void getMessageHistory() async {
    final messagesette =
        await GroupApiService.getGroupChatMessages(groupId: widget.group.id!);
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
    _voiceRecorder.dispose();
    _scrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void sendMessage({List<Attachment>? attachments}) async {
    final text = _controller.text;
    if ((text.isNotEmpty || (attachments != null && attachments.isNotEmpty)) &&
        mounted) {
      try {
        // Send message via API
        String messageId = await ChatApiService.sendChatMessage(
          isGroup: true,
          Id: widget.group.id!,
          content: text.isNotEmpty ? text : null,
          attachments: attachments, // pass attachments
          type: attachments != null && attachments.isNotEmpty
              ? attachments.first.type
              : 'text',
        );

        if (messageId.isNotEmpty) {
          // Only add to local state if API call was successful
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
      } catch (e) {
        print("Error sending message: $e");
        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message. Please try again.')),
        );
      }
    }
  }

  void setMessage(String type, String message, String fromId,
      {String msgType = 'text', List<Attachment>? attachments}) {
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
      attachments: attachments ?? [],
    );

    setState(() {
      messages.add(messageModel);
    });
  }

  // Media handling methods
  Future<void> _pickFromGallery() async {
    final canAccessPhotos = await requestPermission(Permission.photos);
    if (!canAccessPhotos) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
                'Gallery access is required to pick images. Please enable it from settings.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
      return;
    }

    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);

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

  Future<void> _takePicture() async {
    final canUseCamera = await requestPermission(Permission.camera);
    if (!canUseCamera) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
                'Camera access is required to take photos. Please enable it from settings.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
      return;
    }

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
        String fileUrl = await _uploadFile(file.path);

        final attachment = Attachment(url: fileUrl, type: 'file');

        sendMessage(attachments: [attachment]);
      } catch (e) {
        print("Error uploading document: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload file. Please try again.')),
        );
      }
    }
  }

  Future<String> _uploadFile(String filePath) async {
    File file = File(filePath);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload/'),
    );

    // Determine field name based on file type
    String fieldName = 'file';
    if (filePath.toLowerCase().endsWith('.jpg') ||
        filePath.toLowerCase().endsWith('.jpeg') ||
        filePath.toLowerCase().endsWith('.png')) {
      fieldName = 'image';
    } else if (filePath.toLowerCase().endsWith('.mp3') ||
        filePath.toLowerCase().endsWith('.wav') ||
        filePath.toLowerCase().endsWith('.m4a')) {
      fieldName = 'audio';
    }

    request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      return _extractFileUrl(responseBody);
    } else {
      var responseBody = await response.stream.bytesToString();
      print("Upload failed: $responseBody");
      throw Exception('Failed to upload file');
    }
  }

  String _extractFileUrl(String responseBody) {
    final responseJson = jsonDecode(responseBody);
    print("File upload response: $responseJson");
    return responseJson['data'];
  }

  // Emoji picker functionality
  void _onEmojiSelected(Category? category, Emoji emoji) {
    setState(() {
      _controller.text += emoji.emoji;
    });
  }

  // Attachment modal
  void _showAttachmentModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 200,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _attachmentOption(
                    icon: Icons.insert_drive_file,
                    label: 'Document',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      _pickDocument();
                    },
                  ),
                  _attachmentOption(
                    icon: Icons.photo,
                    label: 'Gallery',
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      _pickFromGallery();
                    },
                  ),
                  _attachmentOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    color: Colors.pink,
                    onTap: () {
                      Navigator.pop(context);
                      _takePicture();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(
              icon,
              size: 30,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          _onEmojiSelected(category, emoji);
        },
        onBackspacePressed: () {
          final text = _controller.text;
          if (text.isNotEmpty) {
            final newText = text.characters.skipLast(1).toString();
            _controller.text = newText;
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: newText.length),
            );
          }
        },
        config: Config(
          height: 250,
          checkPlatformCompatibility: true,
          categoryViewConfig: CategoryViewConfig(
            tabIndicatorAnimDuration: Duration(milliseconds: 300),
            categoryIcons: const CategoryIcons(),
            iconColor: Colors.grey,
            iconColorSelected: Color(0xFFE8D5B5),
            indicatorColor: Color(0xFFE8D5B5),
            dividerColor: Colors.grey.shade200,
          ),
          bottomActionBarConfig: BottomActionBarConfig(
            backgroundColor: Color(0xFFE8D5B5),
            buttonColor: Color(0xFFE8D5B5),
            buttonIconColor: Colors.white,
          ),
          skinToneConfig: const SkinToneConfig(),
        ),
      ),
    );
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
                                    type:
                                        message.attachments?.isNotEmpty == true
                                            ? message.attachments!.first.type
                                            : 'text',
                                    attachments: message.attachments,
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
                                type: message.attachments?.isNotEmpty == true
                                    ? message.attachments!.first.type
                                    : 'text',
                                attachments: message.attachments,
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
                          child: Stack(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 12.0),
                              color: kScaffoldColor,
                              child: Row(
                                children: [
                                  // Emoji button
                                  SizedBox(
                                    width: 40,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                      icon: Icon(
                                        _showEmojiKeyboard
                                            ? Icons.keyboard
                                            : Icons.emoji_emotions_outlined,
                                        size: 22,
                                        color: Colors.grey[600],
                                      ),
                                      onPressed: () {
                                        // Hide recording if active when emoji is pressed
                                        if (_isRecording) {
                                          setState(() {
                                            _isRecording = false;
                                          });
                                        }

                                        setState(() {
                                          _showEmojiKeyboard =
                                              !_showEmojiKeyboard;
                                        });

                                        if (_showEmojiKeyboard) {
                                          FocusScope.of(context).unfocus();
                                        } else {
                                          FocusScope.of(context)
                                              .requestFocus(focusNode);
                                        }
                                      },
                                    ),
                                  ),

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
                                            maxHeight: 150,
                                          ),
                                          child: Scrollbar(
                                            thumbVisibility: true,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.vertical,
                                              reverse: true,
                                              child: Row(
                                                children: [
                                                  // Text field
                                                  Expanded(
                                                    child: TextField(
                                                      controller: _controller,
                                                      focusNode: focusNode,
                                                      keyboardType:
                                                          TextInputType
                                                              .multiline,
                                                      maxLines: null,
                                                      minLines: 1,
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
                                                                        8),
                                                      ),
                                                      onChanged: (text) {
                                                        setState(() {});
                                                      },
                                                    ),
                                                  ),

                                                  // Attachment and camera buttons
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      SizedBox(
                                                        width: 32,
                                                        child: IconButton(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          constraints:
                                                              BoxConstraints(),
                                                          icon: const Icon(
                                                            Icons.attach_file,
                                                            size: 20,
                                                            color: Colors.grey,
                                                          ),
                                                          onPressed:
                                                              _showAttachmentModal,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 32,
                                                        child: IconButton(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          constraints:
                                                              BoxConstraints(),
                                                          icon: const Icon(
                                                            Icons.camera_alt,
                                                            size: 20,
                                                            color: Colors.grey,
                                                          ),
                                                          onPressed:
                                                              _takePicture,
                                                        ),
                                                      ),
                                                    ],
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
                                        right: 2, left: 2),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: kPrimaryColor,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: IconButton(
                                        icon: _controller.text.isEmpty
                                            ? Icon(Icons.mic,
                                                color: Colors.white)
                                            : Icon(Icons.send,
                                                color: Colors.white),
                                        onPressed: () async {
                                          if (_controller.text.isEmpty) {
                                            // Hide emoji picker if open
                                            if (_showEmojiKeyboard) {
                                              setState(() {
                                                _showEmojiKeyboard = false;
                                              });
                                            }

                                            if (!_isRecording) {
                                              await _voiceRecorder.init();
                                              await _voiceRecorder
                                                  .startRecording();
                                              setState(() {
                                                _isRecording = true;
                                              });
                                            } else {
                                              File recordedFile =
                                                  await _voiceRecorder
                                                      .stopRecording();
                                              setState(() {
                                                _isRecording = false;
                                                _recordedFile = recordedFile;
                                              });
                                              String audioUrl =
                                                  await audioUpload(
                                                      _recordedFile!.path);
                                              sendMessage(attachments: [
                                                Attachment(
                                                    url: audioUrl,
                                                    type: 'voice')
                                              ]);
                                            }
                                          } else {
                                            sendMessage();
                                            _controller.clear();
                                            setState(() {});
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // VoiceRecorder overlay using the same widget as individual chat
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
                                    File recordedFile =
                                        await _voiceRecorder.stopRecording();
                                    setState(() {
                                      _isRecording = false;
                                      _recordedFile = recordedFile;
                                    });
                                    String audioUrl =
                                        await audioUpload(_recordedFile!.path);
                                    sendMessage(attachments: [
                                      Attachment(url: audioUrl, type: 'voice')
                                    ]);
                                  },
                                  onLock: () =>
                                      setState(() => _isLocked = true),
                                  onUnlock: () =>
                                      setState(() => _isLocked = false),
                                ),
                              ),

                            // Emoji picker (positioned above voice recorder if recording)
                            if (_showEmojiKeyboard)
                              Positioned(
                                bottom: _isRecording ? 110 : 75,
                                left: 0,
                                right: 0,
                                child: _buildEmojiPicker(),
                              ),
                          ]),
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
