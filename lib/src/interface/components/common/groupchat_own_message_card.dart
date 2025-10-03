
import 'package:flutter/material.dart';
import 'package:hef/src/data/models/msg_model.dart';
import 'package:hef/src/interface/components/common/attachment_viewer.dart';
import 'package:hef/src/interface/components/common/voice_message_player.dart';
import 'package:hef/src/data/services/document_service.dart';
import 'package:hef/src/data/constants/color_constants.dart';

class GroupchatOwnMessageCard extends StatelessWidget {
  const GroupchatOwnMessageCard({
    super.key,
    required this.message,
    required this.time,
    required this.status,
    required this.username,
    this.type = "text",
    this.fileUrl,
    this.attachments,
  });

  final String username;
  final String message;
  final String time;
  final String status;
  final String type;
  final String? fileUrl;
  final List<Attachment>? attachments;

  void _openAttachmentViewer(BuildContext context, Attachment attachment, String heroTag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttachmentViewer(
          attachment: attachment,
          heroTag: heroTag,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    Widget buildAttachment() {
      if (attachments != null && attachments!.isNotEmpty) {
        final attachment = attachments!.first;
        final heroTag = 'own_${attachment.url}_${time}';

        switch (attachment.type) {
          case "image":
            return GestureDetector(
              onTap: () => _openAttachmentViewer(context, attachment, heroTag),
              child: Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    attachment.url,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          case "file":
            return GestureDetector(
              onTap: () => _openAttachmentViewer(context, attachment, heroTag),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kBlue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file, color: kBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        attachment.url.split('/').last,
                        style: const TextStyle(
                          color: kBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download, color: kBlue, size: 20),
                      onPressed: () => DocumentService.downloadAndOpenDocument(
                        url: attachment.url,
                        context: context,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            );
          case "voice":
            return VoiceMessagePlayer(
              audioUrl: attachment.url,
              backgroundColor: kWhite.withOpacity(0.8),
              iconColor: kPrimaryColor,
            );
          case "video":
            return GestureDetector(
              onTap: () => _openAttachmentViewer(context, attachment, heroTag),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200,
                    color: Colors.black12,
                    child: const Center(
                      child: Icon(Icons.play_circle_fill, size: 50, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text("Video message"),
                ],
              ),
            );
          default:
            return Text(message, style: const TextStyle(fontSize: 16, color: Colors.black87));
        }
      } else {
        return Text(message, style: const TextStyle(fontSize: 16, color: Colors.black87));
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Color(0xFFE6FFE2),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(username, style: TextStyle(color: Colors.red)),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: buildAttachment(),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.done_all,
                      size: 20,
                      color: status == 'seen' ? Colors.blue[300] : Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
