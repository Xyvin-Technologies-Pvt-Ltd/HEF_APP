import 'dart:convert';
import 'dart:developer';
import 'package:hef/src/data/models/subscription_model.dart';
import 'package:http/http.dart' as http;
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'user_data.g.dart';

@riverpod
Future<UserModel> fetchUserDetails(
    FetchUserDetailsRef ref, String userId) async {
  final url = Uri.parse('$baseUrl/user/single/$userId');
  print('Requesting URL: $url');
  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  log(response.body);
  if (response.statusCode == 200) {
    final dynamic data = json.decode(response.body)['data'];
    return UserModel.fromJson(data);
  } else {
    print(json.decode(response.body)['message']);

    throw Exception(json.decode(response.body)['message']);
  }
}

Future<List<UserModel>> fetchMultipleUsers(
    {required List<String> users}) async {
  final List<UserModel> userList = [];
  log('im inside multiple user ');
  for (var userId in users) {
    try {
      log('im inside multiple user fetching');
      final url = Uri.parse('$baseUrl/user/single/$userId');
      print('Requesting URL: $url');

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = UserModel.fromJson(data['data']);
        userList.add(user);
        print('Fetched user: $user');
      } else {
        print(
            'Failed to fetch user $userId: ${json.decode(response.body)['message']}');
        throw Exception(json.decode(response.body)['message']);
      }
    } catch (e) {
      print('Error fetching user $userId: $e');
    }
  }

  return userList;
}

@riverpod
Future<Subscription?> getSubscription(GetSubscriptionRef ref) async {
  final String url = '$baseUrl/subscription/single/$id';
  log('requesting url:$url');
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body)['data'];
      return Subscription.fromJson(data);
    } else {
      print('Failed to load data. Status code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error in loading subscription details: $e');
    return null;
  }
}
