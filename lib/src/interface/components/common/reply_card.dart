import 'package:flutter/material.dart';
import 'package:hef/src/data/models/msg_model.dart';


// class ReplyCard extends StatelessWidget {
//   const ReplyCard({
//     Key? key,
//     required this.message,
//     required this.time,
//     this.status,
//     this.product,
//     this.business,
//   }) : super(key: key);

//   final String message;
//   final String time;
//   final ChatProduct? product;
//   final String? status;
//   final ChatBusiness? business;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Align(
//         alignment: Alignment.centerLeft, // Aligning for replies
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.7,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF2F2F2), // Light color for reply message
//               borderRadius: BorderRadius.circular(15),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.3),
//                   spreadRadius: 1,
//                   blurRadius: 5,
//                   offset: const Offset(0, 3),
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
//                 if (business?.image != null)
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => MyBusinessesPage(),
//                           ));
//                     },
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(15),
//                       child: Image.network(
//                         business!.image!,
//                         height: 160, // Adjusted height to fit better
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 if (product != null)
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => MyProductPage(),
//                           ));
//                     },
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           product?.name ?? '',
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Color(
//                                 0xFF004797), // Using the same color for emphasis
//                           ),
//                         ),
//                         const SizedBox(
//                             height: 4), // Add spacing between name and price
//                         Text(
//                           'PRICE INR ${product?.price?.toStringAsFixed(2) ?? ''}', // Format price to two decimals
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                             color: Colors
//                                 .black87, // Subtle color for the price text
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 5),
//                   child: Text(
//                     message,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       color: Colors.black87,
//                     ),
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
//                     const SizedBox(width: 5),
//                     // Icon(
//                     //   Icons.done_all,
//                     //   size: 20,
//                     //   color: status == 'seen' ? Colors.blue[300] : Colors.grey,
//                     // ),
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

class ReplyCard extends StatelessWidget {
  const ReplyCard({
    Key? key,
    required this.message,
    required this.time,
    this.status,
    this.product,
    this.business,
    this.attachments,
  }) : super(key: key);

  final String message;
  final String time;
  final ChatProduct? product;
  final ChatBusiness? business;
  final String? status;
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
        final heroTag = 'reply_${attachment.url}_${time}';
        
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
            return Text(message);
        }
      } else {
        return Text(message, style: const TextStyle(fontSize: 16, color: Colors.black87));
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                if (business?.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      business!.image!,
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
