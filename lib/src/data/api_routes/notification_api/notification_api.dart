import 'dart:convert';
import 'package:http/http.dart'as http;
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
