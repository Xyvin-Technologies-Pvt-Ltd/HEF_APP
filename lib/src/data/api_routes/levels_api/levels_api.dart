import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/district_model.dart';
import 'package:hef/src/data/models/level_models/level_model.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'levels_api.g.dart';

class HierarchyApiService {
  const HierarchyApiService();

  Map<String, String> get _headers => {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

  Future<List<LevelModel>> fetchStates() async {
    final url = Uri.parse('$baseUrl/hierarchy/state/list');
    log('Requesting URL: $url');

    final response = await http.get(url, headers: _headers);
    log(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final stateJson = data['data'] as List<dynamic>? ?? [];
      return stateJson.map((e) => LevelModel.fromJson(e)).toList();
    } else {
      final message = json.decode(response.body)['message'];
      log(message);
      throw Exception(message);
    }
  }

  Future<List<LevelModel>> fetchLevelData(String id, String level) async {
    final url = Uri.parse('$baseUrl/hierarchy/levels/$id/$level');
    log('Requesting URL: $url');

    final response = await http.get(url, headers: _headers);
    log(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final levelJson = data['data'] as List<dynamic>? ?? [];
      return levelJson.map((e) => LevelModel.fromJson(e)).toList();
    } else {
      final message = json.decode(response.body)['message'];
      log(message);
      throw Exception(message);
    }
  }

  Future<List<UserModel>> fetchChapterMemberData(String id, String level) async {
    final url = Uri.parse('$baseUrl/hierarchy/levels/$id/$level');
    log('Requesting URL: $url');

    final response = await http.get(url, headers: _headers);
    log(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final memberJson = data['data'] as List<dynamic>? ?? [];
      return memberJson.map((e) => UserModel.fromJson(e)).toList();
    } else {
      final message = json.decode(response.body)['message'];
      log(message);
      throw Exception(message);
    }
  }

  Future<List<DistrictModel>> fetchDistricts() async {
    final url = Uri.parse('$baseUrl/hierarchy/district/list');
    log('Requesting URL: $url');

    final response = await http.get(url, headers: _headers);
    log(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final districtsJson = data['data'] as List<dynamic>? ?? [];
      return districtsJson.map((e) => DistrictModel.fromJson(e)).toList();
    } else {
      final message = json.decode(response.body)['message'];
      log(message);
      throw Exception(message);
    }
  }
}
@riverpod
HierarchyApiService hierarchyApiService(Ref ref) {
  return const HierarchyApiService();
}

@riverpod
Future<List<LevelModel>> fetchStates(Ref ref) {
  final api = ref.watch(hierarchyApiServiceProvider);
  return api.fetchStates();
}

@riverpod
Future<List<LevelModel>> fetchLevelData(Ref ref, String id, String level) {
  final api = ref.watch(hierarchyApiServiceProvider);
  return api.fetchLevelData(id, level);
}

@riverpod
Future<List<UserModel>> fetchChapterMemberData(Ref ref, String id, String level) {
  final api = ref.watch(hierarchyApiServiceProvider);
  return api.fetchChapterMemberData(id, level);
}

@riverpod
Future<List<DistrictModel>> fetchDistricts(Ref ref) {
  final api = ref.watch(hierarchyApiServiceProvider);
  return api.fetchDistricts();
}
