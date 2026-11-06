import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hef/src/data/api_routes/chat_api/chat_api.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/models/chat_model.dart';
import 'package:hef/src/data/models/msg_model.dart';
import 'package:hef/src/data/notifiers/active_chat_tracker.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:hef/src/data/services/audio_upload.dart';
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:hef/src/data/services/voice_recorder.dart';
import 'package:hef/src/interface/components/Dialogs/blockPersonDialog.dart';
import 'package:hef/src/interface/components/Dialogs/report_dialog.dart';
import 'package:hef/src/interface/components/common/message_actions_sheet.dart';
import 'package:hef/src/interface/components/common/own_message_card.dart';
import 'package:hef/src/interface/components/common/reply_card.dart';
import 'package:hef/src/interface/components/common/date_header.dart';
import 'package:hef/src/interface/screens/main_pages/profile/profile_preview.dart';
import 'package:hef/src/interface/screens/main_pages/chat/voice_recorder_widget.dart';
import 'package:intl/intl.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'dart:io';
import 'package:hef/src/data/services/image_upload.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final VoiceRecorder _voiceRecorder = VoiceRecorder();

  File? _recordedFile;
  final Set<String> _deletingMessageIds = {};

  @override
  void initState() {
    super.initState();
    if (widget.receiver.id != null) {
      ActiveChatTracker.instance.setActive(chatId: widget.receiver.id!);
    }
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
    ActiveChatTracker.instance.clear(chatId: widget.receiver.id);
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

  Future<void> _takePicture() async {
    final File? photo = await MediaService().pickImageFromCamera();

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

  Future<void> _handleAttachment() async {
    final result = await pickMedia(
      context: context,
      showDocument: true, // Allow documents in chat
    );

    if (result == null) return;

    if (result is XFile) {
      // It's an image from camera or gallery
      try {
        String imageUrl = await imageUpload(result.path);
        // String imageUrl = result.path;
        final attachment = Attachment(url: imageUrl, type: 'image');
        sendMessage(attachments: [attachment]);
      } catch (e) {
        print("Error uploading image: $e");
      }
    } else if (result is FilePickerResult) {
      // It's a file/document
      try {
        File file = File(result.files.single.path!);
        String fileUrl = await imageUpload(file.path);
        final attachment = Attachment(url: fileUrl, type: 'file');
        sendMessage(attachments: [attachment]);
      } catch (e) {
        print("Error uploading document: $e");
      }
    }
  }

  Widget _buildEmojiPicker() {
    if (!_showEmojiKeyboard) return const SizedBox.shrink();

    return SizedBox(
      height: 250,
      child: EmojiPicker(
        onEmojiSelected: _onEmojiSelected,
        onBackspacePressed: () {
          // Handle backspace - remove last character
          final text = _controller.text;
          if (text.isNotEmpty) {
            final newText = text.characters.skipLast(1).toString();
            _controller.text = newText;
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: newText.length),
            );
          }
        },
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
          height: 250,
          bottomActionBarConfig: BottomActionBarConfig(
            backgroundColor: kPrimaryLightColor,
            buttonColor: kPrimaryColor,
          ),
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

  bool _shouldShowDateHeader(int index) {
    if (index == messages.length - 1) return true;
    final current = messages[index].createdAt?.toLocal();
    final next = messages[index + 1].createdAt?.toLocal();
    if (current == null || next == null) return false;
    final currentDay = DateTime(current.year, current.month, current.day);
    final nextDay = DateTime(next.year, next.month, next.day);
    return currentDay != nextDay;
  }

  Future<void> _onMessageLongPress(MessageModel message) async {
    final isOwn = message.from == widget.sender.id;
    final hasServerId = message.id != null && message.id!.isNotEmpty;
    final canCopy = (message.content?.trim().isNotEmpty ?? false) &&
        !message.isDeleted;
    final canDelete = isOwn && !message.isDeleted && hasServerId;
    final canReport = !isOwn && !message.isDeleted;

    if (!canCopy && !canDelete && !canReport) return;

    final action = await showMessageActionsSheet(
      context: context,
      isOwnMessage: isOwn,
      canCopy: canCopy,
      canDelete: canDelete,
      canReport: canReport,
    );

    if (!mounted) return;
    await handleMessageAction(
      context: context,
      action: action,
      messageId: message.id,
      content: message.content,
      onDeleteConfirmed: () => _deleteMessage(message),
    );
  }

  Future<void> _deleteMessage(MessageModel message) async {
    final messageId = message.id;
    if (messageId == null || messageId.isEmpty) {
      SnackbarService().showSnackBar('Unable to delete yet. Try again shortly.');
      return;
    }
    if (_deletingMessageIds.contains(messageId)) return;

    _deletingMessageIds.add(messageId);
    final index = messages.indexWhere((m) => m.id == messageId);
    MessageModel? previous;
    if (index != -1) {
      previous = messages[index];
      setState(() {
        messages[index] = previous!.copyWith(isDeleted: true);
      });
    }

    final success = await ChatApiService.deleteMessage(messageId: messageId);
    _deletingMessageIds.remove(messageId);

    if (!mounted) return;

    if (success) {
      SnackbarService().showSnackBar('Message deleted');
      ref.invalidate(fetchChatThreadProvider);
    } else {
      if (previous != null && index != -1 && index < messages.length) {
        setState(() {
          messages[index] = previous!;
        });
      }
      SnackbarService().showSnackBar('Failed to delete message. Please try again.');
    }
  }

  Future<void> _callReceiver(String? phone) async {
    final trimmed = phone?.trim() ?? '';
    if (trimmed.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: trimmed);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _headerIdentity({
    required VoidCallback? onProfile,
    required String? phone,
  }) {
    final name = Text(
      widget.receiver.name ?? '',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A1A),
        height: 1.15,
      ),
    );

    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 40),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(width: 2),
        ClipOval(
          child: Container(
            width: 40,
            height: 40,
            color: const Color(0xFFF3F3F3),
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
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: onProfile,
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                name,
                const SizedBox(height: 2),
                const Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFF25C45E),
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(width: 8, height: 8),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF25C45E),
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: () => _callReceiver(phone),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 40),
          icon: const Icon(
            Icons.phone_outlined,
            size: 22,
            color: Color(0xFF1A1A1A),
          ),
        ),
        IconButton(
          onPressed: () {},
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 40),
          icon: const Icon(
            Icons.videocam_outlined,
            size: 24,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildDeletedBubble({required bool isOwn}) {
    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isOwn ? 56 : 16,
          right: isOwn ? 16 : 56,
          top: 8,
          bottom: 8,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isOwn ? const Color(0xFFE2F9DC) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: isOwn
              ? null
              : Border.all(color: const Color(0xFFE6E4E0)),
        ),
        child: const Text(
          'This message was deleted',
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: kGreyDarker,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messageStream = ref.watch(messageStreamProvider);

    messageStream.whenData((newMessage) {
      // Only apply messages for this 1:1 conversation (both directions).
      final involvesThisChat =
          (newMessage.from == widget.receiver.id &&
              newMessage.to == widget.sender.id) ||
          (newMessage.from == widget.sender.id &&
              newMessage.to == widget.receiver.id);

      if (!involvesThisChat) return;

      final existingIndex = messages.indexWhere(
        (m) =>
            (newMessage.id != null &&
                newMessage.id!.isNotEmpty &&
                m.id != null &&
                m.id == newMessage.id) ||
            (m.createdAt == newMessage.createdAt &&
                m.content == newMessage.content &&
                m.from == newMessage.from),
      );

      if (existingIndex != -1) {
        if (newMessage.isDeleted ||
            messages[existingIndex].isDeleted != newMessage.isDeleted ||
            (messages[existingIndex].id == null && newMessage.id != null)) {
          setState(() {
            messages[existingIndex] = newMessage.isDeleted
                ? messages[existingIndex].copyWith(isDeleted: true)
                : newMessage;
          });
        }
        return;
      }

      if (!newMessage.isDeleted) {
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
            appBar: AppBar(
                  toolbarHeight: 68,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.white,
                  backgroundColor: Colors.white,
                  systemOverlayStyle: SystemUiOverlayStyle.dark,
                  automaticallyImplyLeading: false,
                  titleSpacing: 4,
                  leadingWidth: 0,
                  centerTitle: false,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1),
                    child: Container(
                      height: 1,
                      color: const Color(0xFFF0EEEB),
                    ),
                  ),
                  actions: [
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Color(0xFF1A1A1A),
                        size: 24,
                      ),
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
                  title: Consumer(
                    builder: (context, ref, child) {
                      final asyncUser = ref.watch(
                          fetchUserDetailsProvider(widget.receiver.id ?? ''));
                      return asyncUser.when(
                        data: (user) {
                          return _headerIdentity(
                            phone: user.phone,
                            onProfile: () {
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
                          );
                        },
                        loading: () => _headerIdentity(
                          phone: null,
                          onProfile: null,
                        ),
                        error: (error, stackTrace) {
                          return _headerIdentity(
                            phone: null,
                            onProfile: null,
                          );
                        },
                      );
                    },
                  ),
            ),
            backgroundColor: const Color(0xFFFEFDF9),
            body: ColoredBox(
              color: const Color(0xFFFEFDF9),
              child: PopScope(
                child: Column(
                  children: [
                    Expanded(
                      child: messages.isNotEmpty
                          ? ListView.builder(
                              reverse: true,
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message =
                                    messages[messages.length - 1 - index];
                                final actualIndex = messages.length - 1 - index;

                                // Build the message widget
                                Widget messageWidget;
                                if (message.isDeleted) {
                                  messageWidget = GestureDetector(
                                    onLongPress: () =>
                                        _onMessageLongPress(message),
                                    child: _buildDeletedBubble(
                                      isOwn: message.from == widget.sender.id,
                                    ),
                                  );
                                } else if (message.from == widget.sender.id) {
                                  messageWidget = GestureDetector(
                                    onLongPress: () =>
                                        _onMessageLongPress(message),
                                    child: OwnMessageCard(
                                      product: message.product,
                                      requirement: message.feed,
                                      status: message.status!,
                                      message: message.content ?? '',
                                      // 🔹 UPDATE: Determine type from attachments if available
                                      type: message.attachments?.isNotEmpty ==
                                              true
                                          ? message.attachments!.first.type
                                          : 'text',
                                      // 🔹 UPDATE: Pass fileUrl from first attachment
                                      fileUrl:
                                          message.attachments?.isNotEmpty ==
                                                  true
                                              ? message.attachments!.first.url
                                              : null,
                                      // 🔹 UPDATE: Pass the attachments list
                                      attachments: message.attachments,
                                      time: DateFormat('h:mm a').format(
                                        DateTime.parse(
                                                message.createdAt.toString())
                                            .toLocal(),
                                      ),
                                    ),
                                  );
                                } else {
                                  messageWidget = GestureDetector(
                                    onLongPress: () =>
                                        _onMessageLongPress(message),
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

                                // Check if we should show date header
                                if (_shouldShowDateHeader(actualIndex)) {
                                  return Column(
                                    children: [
                                      DateHeader(
                                        date:
                                            message.createdAt ?? DateTime.now(),
                                      ),
                                      messageWidget,
                                    ],
                                  );
                                }

                                return messageWidget;
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
                                color: Colors.white,
                                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                                child: SafeArea(
                                  top: false,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          constraints: const BoxConstraints(
                                            minHeight: 48,
                                            maxHeight: 150,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(26),
                                            border: Border.all(
                                              color: const Color(0xFFE8E8E8),
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 2),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth: 40,
                                                  minHeight: 48,
                                                ),
                                                icon: Icon(
                                                  _showEmojiKeyboard
                                                      ? Icons.keyboard_alt_outlined
                                                      : Icons
                                                          .sentiment_satisfied_outlined,
                                                  size: 24,
                                                  color:
                                                      const Color(0xFF6B6E76),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _showEmojiKeyboard =
                                                        !_showEmojiKeyboard;
                                                  });

                                                  if (_showEmojiKeyboard) {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                  } else {
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
                                                      TextInputType.multiline,
                                                  maxLines: null,
                                                  minLines: 1,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Color(0xFF1A1A1A),
                                                  ),
                                                  decoration:
                                                      const InputDecoration(
                                                    border: InputBorder.none,
                                                    isCollapsed: true,
                                                    hintText:
                                                        'Type a message...',
                                                    hintStyle: TextStyle(
                                                      fontSize: 15,
                                                      color: Color(0xFFA3A4A8),
                                                    ),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 14,
                                                    ),
                                                  ),
                                                  onChanged: (text) {
                                                    setState(() {});
                                                  },
                                                ),
                                              ),
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth: 36,
                                                  minHeight: 48,
                                                ),
                                                icon: const Icon(
                                                  Icons.attach_file,
                                                  size: 22,
                                                  color: Color(0xFF6B6E76),
                                                ),
                                                onPressed: _handleAttachment,
                                              ),
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth: 36,
                                                  minHeight: 48,
                                                ),
                                                icon: const Icon(
                                                  Icons.photo_camera_outlined,
                                                  size: 22,
                                                  color: Color(0xFF6B6E76),
                                                ),
                                                onPressed: _takePicture,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 0),
                                        child: Material(
                                          color: kPrimaryColor,
                                          shape: const CircleBorder(),
                                          child: InkWell(
                                            customBorder: const CircleBorder(),
                                            onTap: () async {
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
                                                        _recordedFile!.path);
                                                sendMessage(
                                                  attachments: [
                                                    Attachment(
                                                        url: audioUrl,
                                                        type: 'voice')
                                                  ],
                                                );
                                              }
                                            } else {
                                              sendMessage();
                                              _controller.clear();
                                              setState(() {});
                                            }
                                            },
                                            child: SizedBox(
                                              width: 48,
                                              height: 48,
                                              child: Icon(
                                                _controller.text.isEmpty
                                                    ? Icons.mic_rounded
                                                    : Icons.send_rounded,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
                                      File recordedFile =
                                          await _voiceRecorder.stopRecording();
                                      setState(() {
                                        _isRecording = false;
                                        _recordedFile = recordedFile;
                                      });
                                      String audioUrl = await audioUpload(
                                          _recordedFile!.path);
                                      sendMessage(
                                        attachments: [
                                          Attachment(
                                              url: audioUrl, type: 'voice')
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
                    // Emoji picker (normal keyboard replacement)
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
}
