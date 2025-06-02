import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/analytics_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

part 'analytics_api.g.dart';

class AnalyticsApiService {
  static final _baseUrl = Uri.parse('$baseUrl/analytic');

  static Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      };

  /// Fetch Analytics
  static Future<List<AnalyticsModel>> fetchAnalytics({
    String? type,
    String? startDate,
    String? endDate,
    String? requestType,
    int? pageNo,
    int? limit,
  }) async {
    final queryParams = <String, String>{};

    if (type?.isNotEmpty ?? false) queryParams['filter'] = type!;
    if (startDate?.isNotEmpty ?? false) queryParams['startDate'] = startDate!;
    if (endDate?.isNotEmpty ?? false) queryParams['endDate'] = endDate!;
    if (requestType?.isNotEmpty ?? false)
      queryParams['requestType'] = requestType!;
    if (pageNo != null) queryParams['pageNo'] = pageNo.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    final url = _baseUrl.replace(queryParameters: queryParams);
    log('Fetching analytics from: $url');
    log("token of analytics  api: $token");
    final response = await http.get(url, headers: _headers());

    final decoded = json.decode(response.body);

    if (response.statusCode == 200) {
      final List data = decoded['data'];
      return data.map((item) => AnalyticsModel.fromJson(item)).toList();
    } else {
      throw Exception(decoded['message'] ?? 'Failed to fetch analytics');
    }
  }

  /// Post Analytics
  Future<String?> postAnalytic({required Map<String, dynamic> data}) async {
    try {
      final response = await http.post(_baseUrl,
          headers: _headers(), body: jsonEncode(data));
      final decoded = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('Analytics posted successfully: ${response.body}');
        return 'success';
      } else {
        return decoded['message'];
      }
    } catch (e) {
      log('Exception in posting analytics: $e');
      return e.toString();
    }
  }

  /// Update Analytics Status
  Future<void> updateAnalyticStatus({
    required String analyticId,
    required String? action,
  }) async {
    final url = Uri.parse('$_baseUrl/status');

    final body = jsonEncode({
      'requestId': analyticId,
      'action': action,
    });

    try {
      final response = await http.post(url, headers: _headers(), body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('$action successfully applied');
      } else {
        log('Failed to update analytic status: ${response.statusCode}');
        log('Response: ${response.body}');
      }
    } catch (e) {
      log('Error updating analytic status: $e');
    }
  }

  /// Delete Analytic
  Future<void> deleteAnalytic({required String analyticId}) async {
    final url = Uri.parse('$_baseUrl/$analyticId');

    try {
      final response = await http.delete(url, headers: _headers());

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('Analytic deleted successfully');
      } else {
        log('Failed to delete analytic: ${response.statusCode}');
        log('Response: ${response.body}');
      }
    } catch (e) {
      log('Error deleting analytic: $e');
    }
  }
}

@riverpod
Future<List<AnalyticsModel>> fetchAnalytics(
  Ref ref, {
  required String? type,
  String? startDate,
  String? endDate,
  String? requestType,
  int? pageNo,
  int? limit,
}) {
  return AnalyticsApiService.fetchAnalytics(
    type: type,
    startDate: startDate,
    endDate: endDate,
    requestType: requestType,
    pageNo: pageNo,
    limit: limit,
  );
}
