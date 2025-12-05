import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/models/level_models/chapter_model.dart';
import 'package:http/http.dart' as http;
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chapter_details.g.dart';

class ChapterApiService {
  static Future<List<UserChapterModel>> fetchAllChapters() async {
    final url = Uri.parse('$baseUrl/user/list?limit=1000');
    print('Requesting URL: $url');
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    log(response.body);
    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body)['data'];
      final usersJson = data as List<dynamic>? ?? [];

      // Extract unique chapters from users
      final Map<String, UserChapterModel> uniqueChapters = {};

      for (final user in usersJson) {
        final chapter = user['chapter'];
        if (chapter != null && chapter['_id'] != null) {
          final chapterId = chapter['_id'] as String;
          if (!uniqueChapters.containsKey(chapterId)) {
            uniqueChapters[chapterId] = UserChapterModel.fromJson(chapter);
          }
        }
      }

      return uniqueChapters.values.toList()
        ..sort((a, b) => (a.name ?? '')
            .toLowerCase()
            .compareTo((b.name ?? '').toLowerCase()));
    } else {
      print(json.decode(response.body)['message']);
      throw Exception(json.decode(response.body)['message']);
    }
  }

  static Future<ChapterDetailsModel> fetchChapterDetails(
      String chapterId) async {
    final url = Uri.parse('$baseUrl/hierarchy/chapter/$chapterId');
    print('Requesting URL: $url');
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    log(response.body);
    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body)['data'];
      return ChapterDetailsModel.fromJson(data);
    } else {
      print(json.decode(response.body)['message']);
      throw Exception(json.decode(response.body)['message']);
    }
  }
}

@riverpod
Future<List<UserChapterModel>> fetchAllChapters(Ref ref) {
  return ChapterApiService.fetchAllChapters();
}

@riverpod
Future<ChapterDetailsModel> fetchChapterDetails(Ref ref, String chapterId) {
  return ChapterApiService.fetchChapterDetails(chapterId);
}
