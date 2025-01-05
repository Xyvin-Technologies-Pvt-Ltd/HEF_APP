import 'dart:convert';
import 'dart:developer';
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:http/http.dart' as http;
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/notification_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_api.g.dart';

@riverpod
Future<List<NotificationModel>> fetchNotifications(
    FetchNotificationsRef ref) async {
  final url = Uri.parse('$baseUrl/notification/user');
  print('Requesting URL: $url');
  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );
  print('hello');
  print(json.decode(response.body)['status']);
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data'];
    print(response.body);
    List<NotificationModel> unReadNotifications = [];

    for (var item in data) {
      unReadNotifications.add(NotificationModel.fromJson(item));
    }
    print(unReadNotifications);
    return unReadNotifications;
  } else {
    print(json.decode(response.body)['message']);

    throw Exception(json.decode(response.body)['message']);
  }
}

Future<void> createLevelNotification({
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
