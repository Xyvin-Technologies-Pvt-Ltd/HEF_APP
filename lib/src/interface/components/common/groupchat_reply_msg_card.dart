
import 'package:flutter/material.dart';
import 'package:hef/src/data/models/msg_model.dart';

class GroupchatReplyMsgCard extends StatelessWidget {
  const GroupchatReplyMsgCard(
      {Key? key,
      required this.message,
      required this.time,
      this.feed,
      required this.username})
      : super(key: key);
  final String username;
  final String message;
  final String time;
  final ChatBusiness? feed;

  @override
  Widget build(BuildContext context) {
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
              color: const Color(0xFFF2F2F2), // Light color for reply message
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: TextStyle(color: Colors.green),
                ),
                if (feed?.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      feed!.image!,
                      height: 160, // Adjusted height to fit better
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
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
                      color: Colors.blue[300],
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
