
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart'as http;
part 'people_api.g.dart';
@riverpod
Future<List<UserModel>> fetchActiveUsers(FetchActiveUsersRef ref,
    {int pageNo = 1, int limit = 10}) async {
  final response = await http.get(
    Uri.parse('$baseUrl/user/list?pageNo=$pageNo&limit=$limit'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final usersJson = data['data'] as List<dynamic>? ?? [];

    return usersJson.map((user) => UserModel.fromJson(user)).toList();
  } else {
    final data = json.decode(response.body);
    log(data['message']);
    throw Exception('Failed to load users');
  }
}