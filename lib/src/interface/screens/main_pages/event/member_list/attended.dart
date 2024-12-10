import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/events_api/events_api.dart';
import 'package:hef/src/data/api_routes/levels_api/levels_api.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/models/events_model.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';

class AttendedPage extends StatelessWidget {
  final Event event;
  const AttendedPage({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    NavigationService navigationService = NavigationService();
    return Consumer(
      builder: (context, ref, child) {
        final asynMemberList =
            ref.watch(fetchEventAttendanceProvider(eventId: event.id ?? ''));

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text("Back"),
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
          body: asynMemberList.when(
            data: (members) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: members.attendedUsers?.length,
                        itemBuilder: (context, index) {
                          final member = members.attendedUsers?[index];
                          return Card(
                            elevation: 0.1,
                            color: kWhite,
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(member?.image ?? ''),
                              ),
                              title: Text(member?.name ?? ''),
                              subtitle: Text(member?.email ?? ''),
                              trailing: Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                navigationService.pushNamed('ProfileAnalytics',
                                    arguments: member);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: LoadingAnimation()),
            error: (error, stackTrace) => Center(
              child: Text('${error.toString()}'),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Handle action
            },
            backgroundColor: Colors.orange,
            child: Icon(Icons.person_add, color: Colors.white),
          ),
        );
      },
    );
  }
}
