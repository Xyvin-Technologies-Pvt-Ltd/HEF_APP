import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/activity_api/activity_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/notifiers/loading_notifier.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:intl/intl.dart';

class ActivityPage extends StatelessWidget {
  final String chapterId;

  ActivityPage({super.key, required this.chapterId});

  @override
  Widget build(BuildContext context) {
    ActivityApiService activityApiService = ActivityApiService();
    return Consumer(
      builder: (context, ref, child) {
        final asyncActivities =
            ref.watch(fetchActivityProvider(chapterId: chapterId));
        return Scaffold(
            appBar: AppBar(
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                Row(
                  children: [
                    IconButton(
                        color: kPrimaryColor,
                        icon: Icon(Icons.download),
                        onPressed: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return LoadingAnimation();
                            },
                          );
                          try {
                            await activityApiService
                                .downloadAndSaveExcel(chapterId);
                          } finally {
                            Navigator.of(context).pop();
                          }
                        }),
                  ],
                )
              ],
              title: Text("Activity"),
              centerTitle: false,
              backgroundColor: Colors.white,
              elevation: 0,
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              iconTheme: IconThemeData(color: Colors.black),
            ),
            body: asyncActivities.when(
                data: (activities) {
                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      String formattedDate =
                          DateFormat('dd.MM.yyyy').format(activity.createdAt!);

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: .5,
                              offset: Offset(3, 3),
                            ),
                          ],
                        ),
                        margin: EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          activity.type == 'Business'
                                              ? 'Business Seller'
                                              : "Host",
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: Colors.grey[300],
                                              child: Icon(Icons.person,
                                                  color: Colors.grey),
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                activity.sender?.name ?? '',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          activity.type == 'Business'
                                              ? 'Business Buyer'
                                              : "Guest",
                                          style: TextStyle(
                                            color: kBlue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                activity.member?.name ?? '',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 5,
                                                textAlign: TextAlign.end,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            CircleAvatar(
                                              backgroundColor: Colors.grey[300],
                                              child: Icon(Icons.person,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (activity.type == 'Referral')
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 20),
                                    Text(
                                      'Referral',
                                      style: TextStyle(
                                        color: kBlack54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text('Name: '),
                                            Expanded(
                                              child: Text(
                                                activity.referral?.name ?? '',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text('Email: '),
                                            Expanded(
                                              child: Text(
                                                activity.referral?.email ?? '',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text('Phone: '),
                                            Expanded(
                                              child: Text(
                                                activity.referral?.phone ?? '',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              Divider(
                                height: 24,
                                thickness: 1,
                                color: const Color.fromARGB(255, 229, 226, 226),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      activity.title ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 5,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  if (activity.type == 'Business')
                                    Text.rich(
                                      TextSpan(
                                        text: 'Amount Paid: ',
                                        style: kSmallTitleB.copyWith(
                                            color: kGreyLight),
                                        children: [
                                          TextSpan(
                                              text: activity.amount.toString(),
                                              style: kSmallTitleB.copyWith(
                                                  color: kBlue)),
                                        ],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  if (activity.type == 'One v One Meeting')
                                    Text(
                                      formattedDate,
                                      style:
                                          kSmallTitleB.copyWith(color: kBlue),
                                    )
                                ],
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: LoadingAnimation()),
                error: (error, stackTrace) {
                  log(name: 'Activity', error.toString());
                  return const Center(child: Text('No Activity Found'));
                }));
      },
    );
  }
}
