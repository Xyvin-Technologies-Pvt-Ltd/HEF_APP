
import 'package:flutter/material.dart';
import 'package:hef/src/data/models/business_model.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:intl/intl.dart';

Widget buildUserInfo(UserModel user, Business feed) {
  String formattedDateTime = DateFormat('h:mm a · MMM d, yyyy')
      .format(DateTime.parse(feed.createdAt.toString()).toLocal());
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        // Make the whole left section flexible
        child: Row(
          children: [
            ClipOval(
              child: Container(
                width: 30,
                height: 30,
                color: const Color.fromARGB(255, 255, 255, 255),
                child: Image.network(
                  user.image ?? 'https://placehold.co/600x400',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/icons/dummy_person_small.png');
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              // Wrap the column with Expanded to allow text wrapping
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.name}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                    overflow:
                        TextOverflow.ellipsis, // Ensures text doesn't overflow
                  ),
                  if (user.company?[0].name != null)
                    Text(
                      user.company![0].name!,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      overflow: TextOverflow
                          .ellipsis, // Allows company name to wrap or be truncated
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      Flexible(
        flex: 1,
        fit: FlexFit.loose,
        child: Text(
          formattedDateTime,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
