import 'dart:convert';
import 'dart:developer';
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:http/http.dart' as http;
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
    print(response.body);
    final feedsJson = data['data'] as List<dynamic>? ?? [];
    log(data['message']);
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

Future<void> uploadBusiness(
    {
    required String? media,
    required String content}) async {
  final url = Uri.parse('$baseUrl/feeds');

  final headers = {
    'accept': '*/*',
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({
    
    if (media != null && media != '') 'media': media,
    'content': content,
  });

  try {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201|| response.statusCode == 200) {
      print('Feed created successfully');
    } else {
      print('Failed to create bussiness: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> deletePost(String postId, context) async {
  SnackbarService snackbarService = SnackbarService();
  final url = Uri.parse('$baseUrl/feeds/single/$postId');
  print('requesting url:$url');
  final response = await http.delete(
    url,
    headers: {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    snackbarService.showSnackBar('Post Deleted Successfully');
    // ScaffoldMessenger.of(context)
    //     .showSnackBar(SnackBar(content: Text('Post Deleted Successfully')));
  } else {
    final jsonResponse = json.decode(response.body);
    snackbarService.showSnackBar(jsonResponse['message']);
    print(jsonResponse['message']);
    print('Failed to delete image: ${response.statusCode}');
  }
}
