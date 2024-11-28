
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart'as http;
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/business_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'business_api.g.dart';

@riverpod
Future<List<Business>> fetchBusiness(FetchBusinessRef ref,
    {int pageNo = 1, int limit = 10}) async {
  final response = await http.get(
    Uri.parse('$baseUrl/feeds/list?pageNo=$pageNo&limit=$limit'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final feedsJson = data['data'] as List<dynamic>? ?? [];

    return feedsJson.map((user) => Business.fromJson(user)).toList();
  } else {
    final data = json.decode(response.body);
    log(data['message']);
    throw Exception('Failed to load Business');
  }
}

@riverpod
Future<List<Business>> fetchMyBusinesses(FetchMyBusinessesRef ref) async {
  final url = Uri.parse('$baseUrl/feeds/my-feeds');
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
    List<Business> posts = [];

    for (var item in data) {
      posts.add(Business.fromJson(item));
    }
    print(posts);
    return posts;
  } else {
    print(json.decode(response.body)['message']);

    throw Exception(json.decode(response.body)['message']);
  }
}
