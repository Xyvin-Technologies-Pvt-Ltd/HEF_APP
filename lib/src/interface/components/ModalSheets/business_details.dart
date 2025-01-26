import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/chat_api/chat_api.dart';
import 'package:hef/src/data/api_routes/review_api/review_api.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/business_model.dart';
import 'package:hef/src/data/models/chat_model.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/components/common/review_barchart.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/screens/main_pages/chat/chat_screen.dart';

class BusinessDetailsModalSheet extends StatelessWidget {
  final VoidCallback onButtonPressed;
  final String buttonText;
  final Business business;
  final Participant sender;
  final Participant receiver;

  const BusinessDetailsModalSheet({
    Key? key,
    required this.onButtonPressed,
    required this.buttonText,
    required this.business,
    required this.sender,
    required this.receiver,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final asyncUser =
            ref.watch(fetchUserDetailsProvider(business.author ?? ''));
        final asyncReviews =
            ref.watch(fetchReviewsProvider(userId: business.author ?? ''));
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height *
                0.8, // Fixed height (75% of screen height)
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 70,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                asyncUser.when(
                  data: (user) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 20),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 36,
                            width: 36,
                            child: ClipOval(
                              child: Image.network(
                                user.image ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                      'assets/icons/dummy_person_small.png');
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${user?.name ?? ''}'),
                              Text('${user.company?[0].name ?? ''}'),
                            ],
                          ),
                          const Spacer(),
                          Consumer(
                            builder: (context, ref, child) {
                              return asyncReviews.when(
                                data: (reviews) {
                                  final averageRating =
                                      getAverageRating(reviews);
                                  final totalReviews = reviews.length;
                                  return Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.orange),
                                      Text(averageRating.toStringAsFixed(2)),
                                      Text('($totalReviews)'),
                                    ],
                                  );
                                },
                                loading: () =>
                                    const Center(child: LoadingAnimation()),
                                error: (error, stackTrace) {
                                  return const Center(child: SizedBox.shrink());
                                },
                              );
                            },
                          )
                        ],
                      ),
                    );
                  },
                  loading: () => const Center(child: LoadingAnimation()),
                  error: (error, stackTrace) {
                    return const Center(
                      child: Text('User not found'),
                    );
                  },
                ),
                if (business.media != null && business.media != '')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.network(
                        business.media ?? '',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                if (business.media != null && business.media != '')
                  const SizedBox(height: 20),
                // Make only the text content scrollable
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(business.content ?? ''),
                ),

                if (id != business.author)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Consumer(
                      builder: (context, ref, child) {
                        return customButton(
                          label: buttonText,
                          onPressed: () async {
                            await sendChatMessage(
                                userId: business.author ?? '',
                                content: business.content ?? '',
                                businessId: business.id);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => IndividualPage(
                                      receiver: receiver,
                                      sender: sender,
                                    )));
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
        );
      },
    );
  }
}

void showBusinessModalSheet({
  required BuildContext context,
  required VoidCallback onButtonPressed,
  required String buttonText,
  required Business business,
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
      return BusinessDetailsModalSheet(
        onButtonPressed: onButtonPressed,
        buttonText: buttonText,
        business: business,
        sender: sender,
        receiver: receiver,
      );
    },
  );
}
