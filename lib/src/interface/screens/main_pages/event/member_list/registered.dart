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
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';

class RegisteredPage extends StatelessWidget {
  final Event event;
  const RegisteredPage({
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
                        itemCount: members.registeredUsers?.length,
                        itemBuilder: (context, index) {
                          final member = members.registeredUsers?[index];
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
                              // subtitle: Text(member?.email ?? ''),
                              subtitle: Text(member?.chapter ?? ''),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    padding: EdgeInsets.zero,
                                    onSelected: (value) async {
                                      if (value != 'remove' ||
                                          member?.id == null ||
                                          event.id == null) return;
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Remove from RSVP'),
                                          content: Text(
                                            'Remove ${member?.name ?? 'this user'} from the event registration?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child: const Text('Remove'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm != true) return;
                                      try {
                                        await EventApiService.removeRsvp(
                                          eventId: event.id!,
                                          userId: member!.id!,
                                        );
                                        ref.invalidate(
                                            fetchEventAttendanceProvider(
                                                eventId: event.id ?? ''));
                                        if (context.mounted) {
                                          SnackbarService().showSnackBar(
                                              'Removed from registration');
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          SnackbarService().showSnackBar(e
                                              .toString()
                                              .replaceFirst('Exception: ', ''));
                                        }
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem<String>(
                                        value: 'remove',
                                        child: Row(
                                          children: [
                                            Icon(Icons.person_remove_outlined),
                                            SizedBox(width: 8),
                                            Text('Remove from RSVP'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.arrow_forward_ios),
                                ],
                              ),
                              onTap: () async {
                                // Show a loading dialog
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return const Center(
                                        child: LoadingAnimation());
                                  },
                                );

                                try {
                                  // Fetch user details
                                  final user = await ref.read(
                                      fetchUserDetailsProvider(member?.id ?? '')
                                          .future);

                                  // Close the loading dialog
                                  Navigator.of(context).pop();

                                  // Navigate to ProfileAnalytics
                                  navigationService.pushNamed(
                                      'ProfileAnalytics',
                                      arguments: user);
                                } catch (error) {
                                  // Close the loading dialog
                                  Navigator.of(context).pop();
                                  SnackbarService snackbarService =
                                      SnackbarService();
                                  snackbarService.showSnackBar(
                                      'Something went wrong please try again later');
                                }
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
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     // Handle action
          //   },
          //   backgroundColor: Colors.orange,
          //   child: Icon(Icons.person_add, color: Colors.white),
          // ),
        );
      },
    );
  }
}
