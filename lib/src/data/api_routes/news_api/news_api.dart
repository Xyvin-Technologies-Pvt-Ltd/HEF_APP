import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/news_model.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'news_api.g.dart';

class NewsApiService {
  const NewsApiService();

  Map<String, String> get _headers => {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

  Future<List<News>> fetchNews() async {
    final url = Uri.parse('$baseUrl/news/user');
    log('Requesting URL: $url');

    final response = await http.get(url, headers: _headers);
    log('Status: ${response.statusCode}');
    log(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((item) => News.fromJson(item)).toList();
    } else {
      final message = json.decode(response.body)['message'];
      log(message);
      throw Exception(message);
    }
  }
}


@riverpod
NewsApiService newsApiService(Ref ref) {
  return const NewsApiService();
}

@riverpod
Future<List<News>> fetchNews(Ref ref) {
  final api = ref.watch(newsApiServiceProvider);
  return api.fetchNews();
}
