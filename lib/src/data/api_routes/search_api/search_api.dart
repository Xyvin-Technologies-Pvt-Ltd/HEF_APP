import 'dart:convert';
import 'dart:developer';

import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/global_search_model.dart';
import 'package:http/http.dart' as http;

class SearchApiService {
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  /// `GET /search?q=&limit=`
  /// Backend returns empty buckets when `q` is shorter than 2 characters.
  Future<GlobalSearchResult> globalSearch({
    required String query,
    int limit = 10,
  }) async {
    final q = query.trim();
    if (q.length < 2) {
      return const GlobalSearchResult();
    }

    final url = Uri.parse('$baseUrl/search').replace(
      queryParameters: {
        'q': q,
        'limit': limit.clamp(1, 20).toString(),
      },
    );

    log('Requesting URL: $url');

    final response = await http
        .get(url, headers: _headers)
        .timeout(const Duration(seconds: 20));

    final responseData = json.decode(response.body) as Map<String, dynamic>;
    log('Global search status: ${responseData['status']}');

    if (response.statusCode == 200) {
      final data = responseData['data'];
      if (data is Map<String, dynamic>) {
        return GlobalSearchResult.fromJson(data);
      }
      if (data is Map) {
        return GlobalSearchResult.fromJson(Map<String, dynamic>.from(data));
      }
      return const GlobalSearchResult();
    }

    final message =
        (responseData['message'] ?? 'Failed to fetch search results').toString();
    log('Global search error: $message');
    throw Exception(message);
  }
}
