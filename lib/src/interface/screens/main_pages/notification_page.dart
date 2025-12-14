import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:hef/src/data/api_routes/notification_api/notification_api.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/notification_model.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  bool _isPdf(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.pdf') || lowerUrl.contains('.pdf?');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      // onWillPop: () async {
      //   return true;
      // },
      child: Consumer(
        builder: (context, ref, child) {
          final asyncNotification = ref.watch(fetchNotificationsProvider);

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                "Notifications",
                style: TextStyle(fontSize: 17),
              ),
              backgroundColor: Colors.white,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              actions: [
                Consumer(
                  builder: (context, ref, child) {
                    final asyncNotifications =
                        ref.watch(fetchNotificationsProvider);
                    final hasNotifications = asyncNotifications.maybeWhen(
                      data: (notifications) => notifications.isNotEmpty,
                      orElse: () => false,
                    );

                    if (!hasNotifications) return SizedBox();

                    return TextButton(
                      onPressed: () async {
                        try {
                          // Show confirmation dialog
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Clear All Notifications'),
                                content: Text(
                                    'Are you sure you want to clear all notifications?'),
                                actions: [
                                  TextButton(
                                    child: Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  TextButton(
                                    child: Text('Clear All'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true) {
                            await NotificationApiService
                                .clearAllNotifications();
                            // Refresh the notifications list
                            ref.invalidate(fetchNotificationsProvider);
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to clear notifications')),
                          );
                        }
                      },
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  asyncNotification.when(
                    data: (notifications) {
                      // Filter out notifications that are cleared for the current user
                      final visibleNotifications =
                          notifications.where((notification) {
                        final userNotification = notification.users?.firstWhere(
                          (user) => user.userId == id,
                          orElse: () => UserNotification(
                              userId: '', read: false, cleared: false),
                        );
                        return !(userNotification?.cleared ?? false);
                      }).toList();

                      if (visibleNotifications.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_none,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No notifications',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: visibleNotifications.length,
                        itemBuilder: (context, index) {
                          final notification = visibleNotifications[index];
                          final userNotification =
                              notification.users?.firstWhere(
                            (user) => user.userId == id,
                            orElse: () => UserNotification(
                                userId: '', read: false, cleared: false),
                          );

                          bool isRead = userNotification?.read ?? false;
                          bool isCleared = userNotification?.cleared ?? false;

                          log('Notification ${index}: read=$isRead, cleared=$isCleared');

                          // Use the real notification ID from the database
                          final realNotificationId = notification.id;
                          log('Notification ID: $realNotificationId, Subject: ${notification.subject}');

                          if (realNotificationId == null ||
                              realNotificationId.isEmpty) {
                            log('ERROR: Notification ID is null or empty!');
                            return SizedBox(); // Skip this notification if no ID
                          }

                          return _buildNotificationCard(
                            readed: isRead,
                            subject: notification.subject ?? '',
                            content: notification.content ?? '',
                            dateTime: notification.updatedAt!,
                            fileUrl: notification.media,
                            notificationId: realNotificationId,
                            ref: ref,
                            context: context,
                          );
                        },
                        padding: EdgeInsets.all(0.0),
                      );
                    },
                    loading: () => Center(child: LoadingAnimation()),
                    error: (error, stackTrace) {
                      return Center(
                        child: Text(''),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard({
    required bool readed,
    required String subject,
    required String content,
    required DateTime dateTime,
    String? fileUrl,
    required String notificationId,
    required WidgetRef ref,
    required BuildContext context,
  }) {
    String time = timeAgo(dateTime);
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
      child: Card(
        elevation: 1,
        color: readed ? Color(0xFFF2F2F2) : Colors.white,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!readed)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Icon(Icons.circle, color: Colors.blue, size: 12),
                    ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subject,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      try {
                        // Show confirmation dialog
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Clear Notification'),
                              content: Text(
                                  'Are you sure you want to clear this notification?'),
                              actions: [
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                ),
                                TextButton(
                                  child: Text('Clear'),
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          log('About to clear notification with ID: $notificationId');
                          await NotificationApiService.clearNotification(
                              notificationId);
                          // Refresh the notifications list
                          ref.invalidate(fetchNotificationsProvider);
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to clear notification')),
                        );
                      }
                    },
                    icon: Icon(Icons.clear, size: 20, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                content,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                softWrap: true,
              ),
              if (fileUrl != null && fileUrl.isNotEmpty) ...[
                SizedBox(height: 12),
                _isPdf(fileUrl)
                    ? GestureDetector(
                        onTap: () async {
                          final uri = Uri.parse(fileUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Container(
                          height: 80,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.picture_as_pdf,
                                  color: Colors.red, size: 40),
                              SizedBox(width: 12),
                              Text(
                                'View PDF',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            fileUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error_outline,
                                          color: Colors.grey[400], size: 40),
                                      SizedBox(height: 8),
                                      Text(
                                        'Failed to load image',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ],
              SizedBox(height: 8),
              Text(
                time,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String timeAgo(DateTime pastDate) {
  DateTime now = DateTime.now();
  Duration difference = now.difference(pastDate);

  // Get the number of days, hours, and minutes
  int days = difference.inDays;
  int hours = difference.inHours % 24;
  int minutes = difference.inMinutes % 60;

  // Generate a human-readable string based on the largest unit
  if (days > 0) {
    return '$days day${days > 1 ? 's' : ''} ago';
  } else if (hours > 0) {
    return '$hours hour${hours > 1 ? 's' : ''} ago';
  } else if (minutes > 0) {
    return '$minutes minute${minutes > 1 ? 's' : ''} ago';
  } else {
    return 'Just now';
  }
}
