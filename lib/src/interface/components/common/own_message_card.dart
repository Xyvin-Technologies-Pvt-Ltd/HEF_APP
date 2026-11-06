// import 'package:flutter/material.dart';
// import 'package:hef/src/data/models/msg_model.dart';


// class OwnMessageCard extends StatelessWidget {
//   const OwnMessageCard(
//       {Key? key,
//       required this.message,
//       required this.time,
//       required this.status,
//       this.product,
//       this.type = "text",
//       this.fileUrl, 
//       this.requirement,
//       this.attachments,
//       })
//       : super(key: key);

//   final String message;
//   final String time;
//   final ChatProduct? product;
//   final String status;
//   final ChatBusiness? requirement;

//    final String type;      // "text", "image", "document", "audio", "video"
//   final String? fileUrl;
//   final List<Attachment>? attachments;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.7,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//             decoration: BoxDecoration(
//               color: Color(0xFFE6FFE2),
//               borderRadius: BorderRadius.circular(15),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.3),
//                   spreadRadius: 1,
//                   blurRadius: 5,
//                   offset: Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (product?.image != null)
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(15),
//                     child: Image.network(
//                       product!.image!,
//                       height: 160, // Adjusted height to fit better
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 if (requirement?.image != null)
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(15),
//                     child: Image.network(
//                       requirement!.image!,
//                       height: 160, // Adjusted height to fit better
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 if (product != null)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         product?.name ?? '',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Color(
//                               0xFF004797), // Using the provided color for emphasis
//                         ),
//                       ),
//                       SizedBox(height: 4), // Add spacing between name and price
//                       Text(
//                         'PRICE INR ${product?.price?.toStringAsFixed(2) ?? ''}', // Format price to two decimals
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color:
//                               Colors.black87, // Subtle color for the price text
//                         ),
//                       ),
//                     ],
//                   ),
//                 // Padding(
//                 //   padding: const EdgeInsets.only(top: 5),
//                 //   child: Text(
//                 //     message,
//                 //     style: TextStyle(
//                 //       fontSize: 16,
//                 //       color: Colors.black87,
//                 //     ),
//                 //   ),
//                 // ),

//                 Padding(
//                   padding: const EdgeInsets.only(top: 5),
//                   child: Builder(
//                     builder: (context) {
//                       switch (type) {
//                         case "image":
//                           return ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: Image.network(
//                               fileUrl ?? message,
//                               height: 200,
//                               width: double.infinity,
//                               fit: BoxFit.cover,
//                             ),
//                           );

//                         case "document":
//                           return Row(
//                             children: [
//                               const Icon(Icons.insert_drive_file, color: Colors.blue),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   message,
//                                   style: const TextStyle(
//                                     color: Colors.blue,
//                                     decoration: TextDecoration.underline,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           );

//                         case "audio":
//                           return Row(
//                             children: [
//                               Icon(Icons.audiotrack, color: Colors.green[700]),
//                               const SizedBox(width: 8),
//                               Text("Voice message"),
//                               // 👉 Later: add an AudioPlayer package (just_audio / audioplayers)
//                             ],
//                           );

//                         case "video":
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Container(
//                                 height: 200,
//                                 color: Colors.black12,
//                                 child: const Center(
//                                   child: Icon(Icons.play_circle_fill, size: 50, color: Colors.black54),
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text("Video message"),
//                             ],
//                           );

//                         default:
//                           return Text(
//                             message,
//                             style: const TextStyle(fontSize: 16, color: Colors.black87),
//                           );
//                       }
//                     },
//                   ),
//                 ),

//                 // Spacing between message and time row
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       time,
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                     SizedBox(width: 5),
//                     Icon(
//                       Icons.done_all,
//                       size: 20,
//                       color: status == 'seen' ? Colors.blue[300] : Colors.grey,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:hef/src/data/models/msg_model.dart';
import 'package:hef/src/interface/components/common/attachment_viewer.dart';
import 'package:hef/src/interface/components/common/voice_message_player.dart';
import 'package:hef/src/data/services/document_service.dart';
import 'package:hef/src/data/constants/color_constants.dart';

class OwnMessageCard extends StatelessWidget {
  const OwnMessageCard({
    Key? key,
    required this.message,
    required this.time,
    required this.status,
    this.product,
    this.type = "text",
    this.fileUrl,
    this.requirement,
    this.attachments,
  }) : super(key: key);

  final String message;
  final String time;
  final ChatProduct? product;
  final ChatBusiness? requirement;
  final String status;
  final String type; // "text", "image", "document", "audio", "video"
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

  static const _messageStyle = TextStyle(
    fontSize: 15,
    height: 1.25,
    color: Color(0xFF2C2C2C),
    fontWeight: FontWeight.w400,
  );

  static const _timeStyle = TextStyle(
    fontSize: 11,
    height: 1.2,
    color: Color(0xFFAAABAF),
    fontWeight: FontWeight.w400,
  );

  Widget _buildImageCard(BuildContext context, Attachment attachment) {
    final heroTag = 'own_${attachment.url}_$time';
    final width = MediaQuery.sizeOf(context).width * 0.72;

    return Padding(
      padding: const EdgeInsets.only(left: 48, right: 16, top: 8, bottom: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: width,
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE6E4E0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _openAttachmentViewer(context, attachment, heroTag),
                child: Hero(
                  tag: heroTag,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AspectRatio(
                      aspectRatio: 1.1,
                      child: Image.network(
                        attachment.url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFF2F2F2),
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image_outlined,
                              color: Color(0xFF9A9A9A)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (message.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Text(message, style: _messageStyle),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 6, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(time, style: _timeStyle),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.done_all,
                      size: 16,
                      color: status == 'seen'
                          ? const Color(0xFF34B7F1)
                          : const Color(0xFFB0B0B0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstAttachment = (attachments != null && attachments!.isNotEmpty)
        ? attachments!.first
        : null;
    if (firstAttachment?.type == 'image' &&
        product == null &&
        requirement == null) {
      return _buildImageCard(context, firstAttachment!);
    }

    final isVoice = firstAttachment?.type == 'voice';
    final screenWidth = MediaQuery.sizeOf(context).width;

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
              useWaveform: true,
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
            return Text(message, style: _messageStyle);
        }
      } else {
        return Text(message, style: _messageStyle);
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        left: isVoice ? 40 : 56,
        right: 16,
        top: 9,
        bottom: 9,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isVoice ? screenWidth * 0.78 : screenWidth * 0.75,
            minWidth: isVoice ? screenWidth * 0.72 : 0,
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(isVoice ? 10 : 14, 12, 12, 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE2F9DC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (product?.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      product!.image!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (requirement?.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      requirement!.image!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (product != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product?.name ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF004797),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'PRICE INR ${product?.price?.toStringAsFixed(2) ?? ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: buildAttachment(),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(time, style: _timeStyle),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.done_all,
                      size: 16,
                      color: status == 'seen'
                          ? const Color(0xFF34B7F1)
                          : const Color(0xFFB0B0B0),
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
