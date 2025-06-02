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

}

@riverpod
Future<List<NotificationModel>> fetchNotifications(
    Ref ref) async {
  return await NotificationApiService.fetchUserNotifications();
}
