import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/business_category_model.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'business_category_api_service.g.dart';

class BusinesscategoryApiService {
  final Map<String, String> _headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };

  Future<List<BusinessCategoryModel>> getBusinessCategories(
      {int pageNo = 1, int limit = 10, String? query}) async {
    Uri url = Uri.parse('$baseUrl/category?page_no=$pageNo&limit=$limit');

    if (query != null && query.isNotEmpty) {
      url = Uri.parse(
          '$baseUrl/category?page_no=$pageNo&limit=$limit&search=$query');
    }

    log('Requesting business categories: $url');

    final response = await http.get(url, headers: _headers);
    final responseData = json.decode(response.body);
    log('Status: ${responseData['status']}');

    if (response.statusCode == 200) {
      final List<dynamic> data = responseData['data'] ?? [];
      return data.map((json) => BusinessCategoryModel.fromJson(json)).toList();
    } else {
      final message =
          responseData['message'] ?? 'Failed to fetch business categories';
      log('Error: $message');
      throw Exception(message);
    }
  }
}

@riverpod
BusinesscategoryApiService businessCategoryApiService(Ref ref) {
  return BusinesscategoryApiService();
}

@riverpod
Future<List<BusinessCategoryModel>> getBusinessCategories(Ref ref,
    {int pageNo = 1, int limit = 10, String? query}) async {
  final businessCategoryApiService =
      ref.watch(businessCategoryApiServiceProvider);
  return businessCategoryApiService.getBusinessCategories(
      pageNo: pageNo, limit: limit, query: query);
}
