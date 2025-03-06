import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/chapter_api/chapter_details.dart';
import 'package:hef/src/data/models/level_models/chapter_model.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/my_subscription.dart';

class UpgradeDialog extends StatelessWidget {
  const UpgradeDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final asynUser = ref.watch(userProvider);

        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: asynUser.when(
                data: (user) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/pngs/upgrade.png',
                        height: 80,
                      ),
                      const SizedBox(height: 20),

                      // Title
                      const Text(
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                        'Upgrade required !',
                      ),
                      const SizedBox(height: 8),

                      // Subtitle
                      Consumer(
                        builder: (context, ref, child) {
                          final asyncChapter = ref.watch(
                              fetchChapterDetailsProvider(
                                  user.chapter?.id ?? ''));
                          return asyncChapter.when(
                            data: (chapterDetails) {
                              // Get the president
                              final president =
                                  chapterDetails.admins.firstWhere(
                                (admin) =>
                                    admin.role.toLowerCase() == 'president',
                                orElse: () => Admin(
                                  user:
                                      AdminDetails(id: '', name: '', phone: ''),
                                  role: '',
                                  id: '',
                                ),
                              );

                              final contactText = president.role.isEmpty
                                  ? 'Chapter Admins'
                                  : 'Chapter President at ${president.user.phone} (${president.user.name})';

                              return SizedBox(
                                child: Text(
                                  'To access premium features such as availability of B2B transaction capability, Personal Digital Card etc. please contact $contactText and ensure payment of State Subscription of Rs. 1000/- per year has been made on your behalf.',
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                            loading: () =>
                                const Center(child: LoadingAnimation()),
                            error: (error, stackTrace) {
                              return Center(
                                child: SizedBox.shrink(),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: customButton(
                                labelColor: Colors.black,
                                sideColor: const Color(0xFFF2F2F7),
                                buttonColor: const Color(0xFFF2F2F7),
                                label: 'Cancel',
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                          )),
                          Flexible(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: customButton(
                                fontSize: 12,
                                label: 'Upgrade',
                                onPressed: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MySubscriptionPage(),
                                      ));
                                }),
                          ))
                        ],
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: LoadingAnimation()),
                error: (error, stackTrace) {
                  return Center(
                    child: SizedBox.shrink(),
                  );
                },
              )),
        );
      },
    );
  }

  // Helper function to build buttons
}
