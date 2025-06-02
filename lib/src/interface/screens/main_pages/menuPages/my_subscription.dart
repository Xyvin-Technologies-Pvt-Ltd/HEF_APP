import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/models/subscription_model.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/preimum_plan.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class MySubscriptionPage extends StatefulWidget {
  @override
  State<MySubscriptionPage> createState() => _MySubscriptionPageState();
}

class _MySubscriptionPageState extends State<MySubscriptionPage> {
  TextEditingController remarksController = TextEditingController();

  File? _paymentImage;

  // void _openModalSheet({required String sheet, required subscriptionType}) {
  //   showModalBottomSheet(
  //       isScrollControlled: true,
  //       context: context,
  //       builder: (context) {
  //         return ShowPaymentUploadSheet(
  //           subscriptionType: subscriptionType,
  //           pickImage: _pickFile,
  //           textController: remarksController,
  //           imageType: 'payment',
  //           paymentImage: _paymentImage,
  //         );
  //       });
  // }

  Future<File?> _pickFile({required String imageType}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
    );

    if (result != null) {
      // Check if the file size is more than or equal to 1 MB (1 MB = 1024 * 1024 bytes)
      // if (result.files.single.size >= 1024 * 1024) {
      //   CustomSnackbar.showSnackbar(context, 'File size cannot exceed 1MB');

      //   return null; // Exit the function if the file is too large
      // }

      // Set the selected file if it's within the size limit
      setState(() {
        _paymentImage = File(result.files.single.path!);
      });
      return _paymentImage;
    }
    return null;
  }

  String? getRenewalYear(String? period) {
    if (period != null) {
      final parts = period.split('-');
      return parts.isNotEmpty ? parts[0] : null;
    } else {
      return '';
    }
  }

  String? getExpiryYear(String? period) {
    if (period != null) {
      final parts = period.split('-');
      return parts.length > 1 ? parts[1] : null;
    } else {
      return '';
    }
  }

  Subscription? membershipSubscription;
  Subscription? appSubscription;
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final asyncSubscriptions = ref.watch(getUserSubscriptionProvider);
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
                data: (subscriptions) {
                  if (subscriptions.isNotEmpty) {
                    membershipSubscription = subscriptions.firstWhere(
                      (subscription) => subscription.category == "membership",
                      orElse: () => Subscription(),
                    );

                    appSubscription = subscriptions.firstWhere(
                      (subscription) => subscription.category == "app",
                      orElse: () => Subscription(),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.only(left: 25, right: 25, top: 20),
                          child: Row(
                            children: [
                              Text(
                                'MEMBERSHIP SUBSCRIPTION',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
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
                                  // Icon Image Section
                                  Image.asset('assets/pngs/basic.png'),
                                  const SizedBox(height: 10),

                                  // Plan Title
                                  const Text(
                                    'Membership Fee',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 5),

                                  // Price Section
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w600),
                                        '₹1000  ',
                                      ),
                                      Text(
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600),
                                        'per year',
                                      ),
                                    ],
                                  ),

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
                                                style: TextStyle(fontSize: 13),
                                              ),
                                              const Spacer(),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Colors.green,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Text(
                                                  appSubscription?.status ==
                                                          'active'
                                                      ? 'Active'
                                                      : 'Inactive',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (getRenewalYear(
                                                      membershipSubscription
                                                          ?.parentSub
                                                          ?.academicYear) !=
                                                  null &&
                                              getRenewalYear(
                                                      membershipSubscription
                                                          ?.parentSub
                                                          ?.academicYear) !=
                                                  '')
                                            SizedBox(
                                              height: 10,
                                            ),
                                          if (getRenewalYear(
                                                      membershipSubscription
                                                          ?.parentSub
                                                          ?.academicYear) !=
                                                  null &&
                                              getRenewalYear(
                                                      membershipSubscription
                                                          ?.parentSub
                                                          ?.academicYear) !=
                                                  '')
                                            Row(
                                              children: [
                                                const Text(
                                                  'Last renewed on:',
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  getRenewalYear(
                                                          membershipSubscription
                                                              ?.parentSub
                                                              ?.academicYear) ??
                                                      '',
                                                  style: const TextStyle(
                                                    decorationColor:
                                                        kPrimaryColor,
                                                    decoration: TextDecoration
                                                        .underline, // Adds underline
                                                    fontStyle: FontStyle
                                                        .italic, // Makes text italic
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: kPrimaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if (getRenewalYear(
                                                      membershipSubscription
                                                          ?.parentSub
                                                          ?.academicYear) !=
                                                  null &&
                                              getRenewalYear(
                                                      membershipSubscription
                                                          ?.parentSub
                                                          ?.academicYear) !=
                                                  '')
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          if (getRenewalYear(
                                                      membershipSubscription
                                                          ?.parentSub
                                                          ?.academicYear) !=
                                                  null &&
                                              getRenewalYear(
                                                      membershipSubscription
                                                          ?.parentSub
                                                          ?.academicYear) !=
                                                  '')
                                            Row(
                                              children: [
                                                const Text(
                                                  'Next renewal on:',
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  getExpiryYear(
                                                          membershipSubscription
                                                              ?.parentSub
                                                              ?.academicYear) ??
                                                      '',
                                                  style: const TextStyle(
                                                    decorationColor:
                                                        kPrimaryColor,
                                                    decoration: TextDecoration
                                                        .underline, // Adds underline
                                                    fontStyle: FontStyle
                                                        .italic, // Makes text italic
                                                    fontSize: 12,
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
                                          255, 233, 246, 255),
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
                                  SizedBox(
                                      width: double.infinity,
                                      child: customButton(
                                          sideColor:
                                              membershipSubscription?.status ==
                                                      'active'
                                                  ? Colors.green
                                                  : Colors.red,
                                          buttonColor:
                                              membershipSubscription?.status ==
                                                      'active'
                                                  ? Colors.green
                                                  : Colors.red,
                                          label: 'SUBSCRIBE',
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const PremiumPlanPage(
                                                    subcriptionType:
                                                        'membership',
                                                  ),
                                                ));

                                            // if (membershipSubscription
                                            //         ?.status !=
                                            //     'accepted') {
                                            //   // _openModalSheet(
                                            //   //     sheet: 'payment',
                                            //   //     subscriptionType:
                                            //   //         'membership');
                                            // }
                                          })),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding:
                              EdgeInsets.only(left: 25, right: 25, top: 20),
                          child: Row(
                            children: [
                              Text(
                                'UPGRADE APP SUBSCRIPTION',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 25, right: 25, top: 20),
                          child: Center(
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
                                  // Icon Image Section
                                  Image.asset(
                                    'assets/pngs/premium.png',
                                    height: 80,
                                  ),
                                  const SizedBox(height: 10),

                                  // Plan Title
                                  const Text(
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 17),
                                    'App’s Premium Fee',
                                  ),
                                  const SizedBox(height: 5),

                                  // Price Section
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 26),
                                        '₹1000 ',
                                      ),
                                      Text(
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15),
                                        'per year',
                                      ),
                                    ],
                                  ),
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
                                                'App Subscription status:',
                                                style: TextStyle(fontSize: 13),
                                              ),
                                              const Spacer(),
                                              Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 5),
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
                                                    appSubscription?.status ==
                                                            'active'
                                                        ? 'Active'
                                                        : 'Inactive',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          if (appSubscription
                                                  ?.parentSub?.academicYear !=
                                              null)
                                            Row(
                                              children: [
                                                const Text(
                                                  'Last renewed on:',
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  getExpiryYear(appSubscription
                                                          ?.parentSub
                                                          ?.academicYear) ??
                                                      '',
                                                  style: const TextStyle(
                                                    decorationColor:
                                                        kPrimaryColor,
                                                    decoration: TextDecoration
                                                        .underline, // Adds underline
                                                    fontStyle: FontStyle
                                                        .italic, // Makes text italic
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: kPrimaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if (appSubscription
                                                  ?.parentSub?.academicYear !=
                                              null)
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          if (appSubscription
                                                  ?.parentSub?.academicYear !=
                                              null)
                                            Row(
                                              children: [
                                                const Text(
                                                  'Next renewal on:',
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  getRenewalYear(appSubscription
                                                          ?.parentSub
                                                          ?.academicYear) ??
                                                      '',
                                                  style: const TextStyle(
                                                    decorationColor:
                                                        kPrimaryColor,
                                                    decoration: TextDecoration
                                                        .underline, // Adds underline
                                                    fontStyle: FontStyle
                                                        .italic, // Makes text italic
                                                    fontSize: 12,
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
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  // Features List
                                  Container(
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 255, 231, 192),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        _buildPremiumCard(
                                            'Self-manage products and services'),
                                        _buildPremiumCard(
                                            'Post requirements (admin approval needed)'),
                                        _buildPremiumCard(
                                            'Search and send enquiries to suppliers'),
                                        _buildPremiumCard(
                                            'Receive product and service enquiries'),
                                        _buildPremiumCard(
                                            'Premium profile features'),
                                        // _buildPremiumCard(
                                        //     'Provide feedback to HEF office'),
                                        // _buildPremiumCard('Chat with everyone'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  SizedBox(
                                      width: double.infinity,
                                      child: customButton(
                                          buttonHeight: 40,
                                          sideColor: const Color(0xFFF76412),
                                          buttonColor: const Color(0xFFF76412),
                                          label: appSubscription?.status !=
                                                  'Premium'
                                              ? 'SUBSCRIBE'
                                              : appSubscription?.status ??
                                                  'SUBSCRIBE',
                                          onPressed: () {
                                            if (appSubscription?.status !=
                                                'Premium') {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const PremiumPlanPage(
                                                      subcriptionType: 'app',
                                                    ),
                                                  ));
                                            }
                                            // if (appSubscription?.status !=
                                            //     'active') {
                                            //   _openModalSheet(
                                            //       sheet: 'payment',
                                            //       subscriptionType: 'app');
                                            // }
                                          })),
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

  Widget _buildPremiumCard(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.orange, size: 18),
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
