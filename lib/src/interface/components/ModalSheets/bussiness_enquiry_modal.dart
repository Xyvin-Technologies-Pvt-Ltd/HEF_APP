
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/chat_api/chat_api.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/business_model.dart';
import 'package:hef/src/data/models/chat_model.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/components/custom_widgets/user_tile.dart';
import 'package:hef/src/interface/screens/main_pages/chat/chat_screen.dart';

void businessEnquiry({
  required BuildContext context,
  required VoidCallback onButtonPressed,
  required String buttonText,
  required Business businesss,
  required UserModel businessAuthor,
  required Participant sender,
  required Participant receiver,
}) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: (context) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          SingleChildScrollView(
            // Make content scrollable
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (businesss.media != null && businesss.media != '')
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20.0)),
                    child: Image.network(
                      businesss.media!,
                      width: double.infinity,
                      height: 200, // Adjust height as needed
                      fit: BoxFit.cover,
                    ),
                  ),
                Consumer(
                  builder: (context, ref, child) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 10),
                      child: buildUserInfo(businessAuthor,businesss,context), // Reuse widget here
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(businesss.content ?? ''),
                ),
                const SizedBox(
                  height: 10,
                ),
                if (businesss.author != id)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Consumer(
                      builder: (context, ref, child) {
                        return customButton(
                          label: buttonText,
                          onPressed: () async {
                            messageSheet(businessAuthor: businessAuthor,
                                context: context,
                                onButtonPressed: () async {},
                                buttonText: 'SEND MESSAGE',
                                feed: businesss,
                                receiver: receiver,
                                sender: sender);
                          },
                          fontSize: 16,
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Positioned(
            right: 5,
            top: -50,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.all(0),
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 4.0,
                    ),
                  ],
                ),
                child: const Icon(Icons.close),
              ),
            ),
          ),
        ],
      );
    },
  );
}




void messageSheet({
  required BuildContext context,
  required UserModel businessAuthor,
  required VoidCallback onButtonPressed,
  required String buttonText,
  required Business feed,
  required Participant sender,
  required Participant receiver,
}) {
  TextEditingController messageController = TextEditingController();
  showModalBottomSheet(
    isScrollControlled: true, // Ensure the sheet size changes with the keyboard
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: (context) {
      // Get the current view insets (keyboard height)
      final bottomInset = MediaQuery.of(context).viewInsets.bottom;

      return Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Padding(
          padding: EdgeInsets.only(
              bottom: bottomInset), // Adjust padding for keyboard
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                          left: 20, right: 20, bottom: 10, top: 20),
                      child: Text(
                        'MESSAGE',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 10, top: 10),
                      child: buildUserInfo(businessAuthor,feed,context), // Reuse widget here
                    ),

                    const SizedBox(height: 10),
                    // Feed content in a row with image on the left and content on the right
                    if (feed.media != null && feed.media != '')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(255, 241, 236, 236),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Feed Image (50x50)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    child: Image.network(
                                      feed.media!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Feed Content
                                Expanded(
                                  child: Text(
                                    feed.content ?? '',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Message input field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: messageController,
                        decoration: const InputDecoration(
                          hintText: 'Add your text',
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                        maxLines: 6,
                        enabled: true, // Set to false to disable the TextField
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Send button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Consumer(
                        builder: (context, ref, child) {
                          return customButton(
                            label: buttonText,
                            onPressed: () async {
                              await sendChatMessage(
                                  Id: feed.author ?? '',
                                  content: feed.content!,
                                  businessId: feed.id);
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => IndividualPage(
                                        receiver: receiver,
                                        sender: sender,
                                      )));
                              await sendChatMessage(
                                  Id: feed.author ?? '',
                                  content: messageController.text);
                            },
                            fontSize: 16,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              // Close button at the top right
              Positioned(
                right: 5,
                top: -50,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(0),
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 4.0,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.close),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}