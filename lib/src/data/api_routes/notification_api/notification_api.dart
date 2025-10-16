import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/notification_model.dart';
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_api.g.dart';

class NotificationApiService {
  final SnackbarService _snackbarService = SnackbarService();

  
 static Future<List<NotificationModel>> fetchUserNotifications() async {
    final url = Uri.parse('$baseUrl/notification/user');
    log('Requesting URL: $url');

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final status = json.decode(response.body)['status'];
    log('Status: $status');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      log('Response Data: $data');

      final notifications = data
          .map((item) => NotificationModel.fromJson(item))
          .toList();

      return notifications;
    } else {
      final message = json.decode(response.body)['message'];
      log('Error: $message');
      throw Exception(message);
    }
  }


  Future<void> sendLevelNotification({
    required String level,
    required List<String> id,
    required String subject,
    required String content,
    String? media,
  }) async {
    final url = Uri.parse('$baseUrl/notification/level');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'level': level,
      'id': id,
      'subject': subject,
      'content': content,
      'type': 'in-app',
      if (media != null) 'media': media,
    });

    log('Sending notification to IDs: $id');
    log('Request Body: $body');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _snackbarService.showSnackBar(responseData['message']);
      } else {
        _snackbarService.showSnackBar(responseData['message']);
      }
    } catch (e) {
      log('Exception occurred: ${e.toString()}');
    }
  }
  
static Future<void> createLevelNotification({
 required String level,
 required List<String> id,
 required String subject,
 required String content,
 String? media,
}) async {
 final url = Uri.parse('$baseUrl/notification/level');
 SnackbarService snackbarService = SnackbarService();
 final headers = {
   'Content-Type': 'application/json',
   'Authorization': 'Bearer $token',
 };
 log('Notification sending ids:$id');
 final body = jsonEncode({
   'level': level,
   'id': id,
   'subject': subject,
   'content': content,
   'type': 'in-app',
   if (media != null) 'media': media,
 });
 log('Notification body:$body');
 try {
   final response = await http.post(
     url,
     headers: headers,
     body: body,
   );

   if (response.statusCode == 200) {
     final data = jsonDecode(response.body);
     snackbarService.showSnackBar(data['message']);
   } else {
     final error = jsonDecode(response.body);
     snackbarService.showSnackBar(error['message']);
   }
 } catch (e) {
   log(e.toString());
 }
}

/// Clear individual notification by marking as cleared
static Future<void> clearNotification(String notificationId) async {
  final url = Uri.parse('$baseUrl/notification/clear/$notificationId');
  log('Clearing notification: $notificationId');

  try {
    final response = await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      log('Notification cleared: ${data['message']}');
    } else {
      final error = json.decode(response.body);
      log('Error clearing notification: ${error['message']}');
      throw Exception(error['message']);
    }
  } catch (e) {
    log('Exception clearing notification: ${e.toString()}');
    throw Exception('Failed to clear notification');
  }
}

/// Clear all notifications for the user
static Future<void> clearAllNotifications() async {
  final url = Uri.parse('$baseUrl/notification/clear-all');
  log('Clearing all notifications');

  try {
    final response = await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      log('All notifications cleared: ${data['message']}');
    } else {
      final error = json.decode(response.body);
      log('Error clearing all notifications: ${error['message']}');
      throw Exception(error['message']);
    }
  } catch (e) {
    log('Exception clearing all notifications: ${e.toString()}');
    throw Exception('Failed to clear all notifications');
  }
}

}

@riverpod
Future<List<NotificationModel>> fetchNotifications(
    Ref ref) async {
  return await NotificationApiService.fetchUserNotifications();
}

@riverpod
Future<void> clearNotification(
    Ref ref,
    String notificationId) async {
  return await NotificationApiService.clearNotification(notificationId);
}

@riverpod
Future<void> clearAllNotifications(Ref ref) async {
  return await NotificationApiService.clearAllNotifications();
}
