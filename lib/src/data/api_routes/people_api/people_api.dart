import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'people_api.g.dart';

class PeopleApiService {

  Future<List<UserModel>> fetchActiveUsers({
    int pageNo = 1,
    int limit = 20,
    String? query,
    String? district,
    List<String>? tags,
  }) async {
    final baseUri = Uri.parse('$baseUrl/user/list');
    
    final queryParams = {
      'pageNo': pageNo.toString(),
      'limit': limit.toString(),
      if (query != null && query.isNotEmpty) 'search': query,
      if (district != null && district.isNotEmpty) 'district': district,
      if (tags != null && tags.isNotEmpty) 'tags': tags.join(','),
    };

    final fullUri = baseUri.replace(queryParameters: queryParams);
    log('Requesting URL: $fullUri');

    final response = await http.get(
      fullUri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      final usersJson = responseData['data'] as List<dynamic>? ?? [];
      return usersJson.map((user) => UserModel.fromJson(user)).toList();
    } else {
      log(responseData['message']);
      throw Exception('Failed to load users');
    }
  }
}

@riverpod
Future<List<UserModel>> fetchActiveUsers(
  Ref ref, {
  int pageNo = 1,
  int limit = 20,
  String? query,
  String? district,
  List<String>? tags,
}) async {
  final service = PeopleApiService();
  return service.fetchActiveUsers(
    pageNo: pageNo,
    limit: limit,
    query: query,
    district: district,
    tags: tags,
  );
}
