import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/business_model.dart';
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'business_api.g.dart';

class BusinessApiService {
  static Future<List<Business>> fetchBusiness({
    int pageNo = 1,
    int limit = 10,
  }) async {
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
      log(data['message']);
      return feedsJson.map((user) => Business.fromJson(user)).toList();
    } else {
      final data = json.decode(response.body);
      log(data['message']);
      throw Exception('Failed to load Business');
    }
  }

  static Future<List<Business>> fetchMyBusinesses() async {
    final url = Uri.parse('$baseUrl/feeds/my-feeds');
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      log(response.body, name: 'MY BUSINESS API');
      return data.map((item) => Business.fromJson(item)).toList();
    } else {
      final message = json.decode(response.body)['message'];
      throw Exception(message);
    }
  }

  static Future<void> uploadBusiness({
    required String? media,
    required String content,
  }) async {
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

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Feed created successfully');
      } else {
        print('Failed to create business: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  static Future<void> deletePost(String postId, BuildContext context) async {
    final snackbarService = SnackbarService();
    final url = Uri.parse('$baseUrl/feeds/single/$postId');

    final response = await http.delete(
      url,
      headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      snackbarService.showSnackBar('Post Deleted Successfully');
    } else {
      final jsonResponse = json.decode(response.body);
      snackbarService.showSnackBar(jsonResponse['message']);
    }
  }
}


@riverpod
Future<List<Business>> fetchBusiness(Ref ref,
    {int pageNo = 1, int limit = 10}) {
  return BusinessApiService.fetchBusiness(pageNo: pageNo, limit: limit);
}

@riverpod
Future<List<Business>> fetchMyBusinesses(Ref ref) {
  return BusinessApiService.fetchMyBusinesses();
}
