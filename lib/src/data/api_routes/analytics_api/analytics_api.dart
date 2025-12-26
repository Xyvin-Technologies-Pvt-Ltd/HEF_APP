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
      // Log the request body before making the API call
      log('========================================');
      log('========================================');

      // Encode data as JSON for logging
      final jsonData = jsonEncode(data);
      log(
        'Posting analytics with request body (JSON format for Postman):\n$jsonData',
        name: 'Analytics API Request',
      );

      final response = await http.post(
        _baseUrl,
        headers: _headers(),
        body: jsonData,
      );
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

    final body = jsonEncode({'requestId': analyticId, 'action': action});

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

  /// Update Analytic
  Future<String?> updateAnalytic({
    required String analyticId,
    required Map<String, dynamic> data,
  }) async {
    final url = Uri.parse('$_baseUrl/$analyticId');

    try {
      final response = await http.put(
        url,
        headers: _headers(),
        body: jsonEncode(data),
      );
      final decoded = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('Analytics updated successfully: ${response.body}');
        return 'success';
      } else {
        return decoded['message'];
      }
    } catch (e) {
      log('Exception in updating analytics: $e');
      return e.toString();
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

  /// Download Analytics (NEW FUNCTION)
  /// Calls the /download-app endpoint to get analytics data for export
  static Future<Map<String, dynamic>?> downloadAnalytics() async {
    try {
      final url = Uri.parse('$_baseUrl/download-app');
      log('Downloading analytics from: $url');
      log("token for download analytics api: $token");

      final response = await http.get(url, headers: _headers());

      final decoded = json.decode(response.body);

      if (response.statusCode == 200) {
        log('Analytics downloaded successfully');
        return decoded;
      } else {
        log('Failed to download analytics: ${response.statusCode}');
        log('Response: ${response.body}');
        throw Exception(decoded['message'] ?? 'Failed to download analytics');
      }
    } catch (e) {
      log('Exception in downloading analytics: $e');
      rethrow;
    }
  }

  /// Convert download response to CSV format
  static String convertToCSV(Map<String, dynamic> downloadResponse) {
    try {
      final data = downloadResponse['data'];
      if (data == null) return '';

      final headers = data['headers'] as List<dynamic>;
      final body = data['body'] as List<dynamic>;

      if (headers.isEmpty || body.isEmpty) return '';

      // Create header row
      final headerRow = headers.map((h) => h['header']).join(',');

      // Create data rows
      final dataRows = body
          .map((item) {
            return headers
                .map((header) {
                  final key = header['key'];
                  final value = item[key]?.toString() ?? '';
                  // Escape commas and quotes in CSV
                  if (value.contains(',') ||
                      value.contains('"') ||
                      value.contains('\n')) {
                    return '"${value.replaceAll('"', '""')}"';
                  }
                  return value;
                })
                .join(',');
          })
          .join('\n');

      return '$headerRow\n$dataRows';
    } catch (e) {
      log('Error converting to CSV: $e');
      return '';
    }
  }

  /// Get analytics data for display
  static List<Map<String, dynamic>> getAnalyticsData(
    Map<String, dynamic> downloadResponse,
  ) {
    try {
      final data = downloadResponse['data'];
      if (data == null) return [];

      return List<Map<String, dynamic>>.from(data['body'] ?? []);
    } catch (e) {
      log('Error getting analytics data: $e');
      return [];
    }
  }

  /// Generate CSV filename with timestamp
  static String generateCSVFilename() {
    final now = DateTime.now();
    final timestamp =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}';
    return 'analytics_export_$timestamp.csv';
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

/// New Riverpod provider for download analytics
@riverpod
Future<Map<String, dynamic>?> downloadAnalyticsProvider(Ref ref) {
  return AnalyticsApiService.downloadAnalytics();
}
