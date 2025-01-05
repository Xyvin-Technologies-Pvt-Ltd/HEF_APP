import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/models/subscription_model.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:intl/intl.dart';

class MySubscriptionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final asyncSubscriptions = ref.watch(getSubscriptionProvider);
        return Scaffold(
            appBar: AppBar(
              title: const Text(
                "My Subscription",
                style: TextStyle(fontSize: 15),
              ),
              backgroundColor: Colors.white,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            backgroundColor: Colors.white,
            body: asyncSubscriptions.when(
                data: (subscription) {
                  String membershipFormattedRenewalDate =
                      subscription?.createdAt == null ||
                              subscription?.createdAt == ''
                          ? ''
                          : DateFormat('dd MMMM yyyy')
                              .format(subscription!.createdAt!);
                  String membershipFormatteNextRenewalDate =
                      subscription?.expiryDate == null ||
                              subscription?.expiryDate == ''
                          ? ''
                          : DateFormat('dd MMMM yyyy')
                              .format(subscription!.expiryDate!);

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 25, right: 25, top: 20),
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  const BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 10),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 218, 206, 206)),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'Membership status:',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              const Spacer(),
                                              if (subscription != null)
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color: Colors.green,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  child: Text(
                                                    subscription?.status ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              const Text(
                                                'Last renewed on:',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              const Spacer(),
                                              Text(
                                                membershipFormattedRenewalDate,
                                                style: const TextStyle(
                                                  decorationColor:
                                                      kPrimaryColor,
                                                  decoration: TextDecoration
                                                      .underline, // Adds underline
                                                  fontStyle: FontStyle
                                                      .italic, // Makes text italic
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: kPrimaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              const Text(
                                                'Next renewal on:',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              const Spacer(),
                                              Text(
                                                membershipFormatteNextRenewalDate,
                                                style: const TextStyle(
                                                  decorationColor:
                                                      kPrimaryColor,
                                                  decoration: TextDecoration
                                                      .underline, // Adds underline
                                                  fontStyle: FontStyle
                                                      .italic, // Makes text italic
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: kPrimaryColor,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Features List
                                  Container(
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 255, 231, 192),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Column(
                                      children: [
                                        _buildBasicCard(
                                            'Access to News and updates'),
                                        _buildBasicCard(
                                            'Access to Product search'),
                                        _buildBasicCard(
                                            'Access to Requirements'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 15),

                                  // Action Button
                                  // SizedBox(
                                  //     width: double.infinity,
                                  //     child: customButton(
                                  //         sideColor:
                                  //             subscription.membership?.status ==
                                  //                     'accepted'
                                  //                 ? Colors.green
                                  //                 : Colors.red,
                                  //         buttonColor:
                                  //             subscription.membership?.status ==
                                  //                     'accepted'
                                  //                 ? Colors.green
                                  //                 : Colors.red,
                                  //         label: subscription.membership?.status
                                  //                 ?.toUpperCase() ??
                                  //             'SUBSCRIBE',
                                  //         onPressed: () {
                                  //           if (subscription.membership?.status !=
                                  //               'accepted') {
                                  //             _openModalSheet(
                                  //                 sheet: 'payment',
                                  //                 subscriptionType: 'membership');
                                  //           }
                                  //         })),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: LoadingAnimation()),
                error: (error, stackTrace) {
                  return const Center(
                      child: Text('Something Went Wrong, Please try again'));
                }));
      },
    );
  }

  Widget _buildBasicCard(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: kPrimaryColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              feature,
            ),
          ),
        ],
      ),
    );
  }
}
