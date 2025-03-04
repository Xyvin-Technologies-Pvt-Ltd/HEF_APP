import 'dart:convert';
import 'dart:developer';

import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/analytics_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

part 'analytics_api.g.dart';

@riverpod
Future<List<AnalyticsModel>> fetchAnalytics(
    FetchAnalyticsRef ref, String? type) async {
  Uri url = Uri.parse('$baseUrl/analytic');

  if (type != null && type != '') {
    url = Uri.parse('$baseUrl/analytic?filter=$type');
  }
  print('Requesting URL: $url');
  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  print(json.decode(response.body)['status']);
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data'];
    print(response.body);
    List<AnalyticsModel> promotions = [];

    for (var item in data) {
      promotions.add(AnalyticsModel.fromJson(item));
    }
    print(promotions);
    return promotions;
  } else {
    print(json.decode(response.body)['message']);

    throw Exception(json.decode(response.body)['message']);
  }
}

Future<void> updateAnalyticStatus({
  required String analyticId,
  required String? action,
}) async {
  final url = Uri.parse('$baseUrl/analytic/status');

  final headers = {
    'accept': '*/*',
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({
    'requestId': analyticId,
    'action': action,
  });
  log(body);
  try {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      log('$action successfully');
    } else {
      log('Failed to update analytic: ${response.statusCode}');
      log('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> deleteAnalytic({
  required String analyticId,
}) async {
  final url = Uri.parse('$baseUrl/analytic/$analyticId');

  final headers = {
    'accept': '*/*',
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  try {
    final response = await http.delete(
      url,
      headers: headers,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
    } else {
      log('Failed to update analytic: ${response.statusCode}');
      log('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<String?> postAnalytic({Map<String, dynamic>? data}) async {
  final url = Uri.parse('$baseUrl/analytic');

  final headers = {
    'accept': '*/*',
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  final body = jsonEncode(data);
  log(name: "Analytic data:", data.toString());
  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Success: ${response.body}');
      return 'success';
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
       return json.decode(response.body)['message'];
    }
  } catch (e) {
    print('Exception: $e');
        return e.toString();
  }
}
