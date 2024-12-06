import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/level_models/level_model.dart';
import 'package:hef/src/data/models/user_model.dart';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'levels_api.g.dart';

@riverpod
Future<List<LevelModel>> fetchStates(
  FetchStatesRef ref,
) async {
  final url = Uri.parse('$baseUrl/hierarchy/state/list');
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
    final data = json.decode(response.body);
    final stateJson = data['data'] as List<dynamic>? ?? [];

    return stateJson.map((user) => LevelModel.fromJson(user)).toList();
  } else {
    print(json.decode(response.body)['message']);

    throw Exception(json.decode(response.body)['message']);
  }
}

@riverpod
Future<List<LevelModel>> fetchLevelData(FetchLevelDataRef ref, String id,String level) async {
  final url = Uri.parse('$baseUrl/hierarchy/levels/$id/$level');
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
    final data = json.decode(response.body);
    final zoneJson = data['data'] as List<dynamic>? ?? [];

    return zoneJson.map((user) => LevelModel.fromJson(user)).toList();
  } else {
    print(json.decode(response.body)['message']);

    throw Exception(json.decode(response.body)['message']);
  }
}


@riverpod
Future<List<UserModel>> fetchChapterMemberData(FetchChapterMemberDataRef ref, String id,String level) async {
  final url = Uri.parse('$baseUrl/hierarchy/levels/$id/$level');
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
    final data = json.decode(response.body);
    final zoneJson = data['data'] as List<dynamic>? ?? [];

    return zoneJson.map((user) => UserModel.fromJson(user)).toList();
  } else {
    print(json.decode(response.body)['message']);

    throw Exception(json.decode(response.body)['message']);
  }
}

// @riverpod
// Future<List<LevelModel>> fetchDistricts(FetchDistrictsRef ref, String zoneId) async {
//   final url = Uri.parse('$baseUrl/hierarchy/levels/$zoneId/state');
//   print('Requesting URL: $url');
//   final response = await http.get(
//     url,
//     headers: {
//       "Content-Type": "application/json",
//       "Authorization": "Bearer $token"
//     },
//   );

//   log(response.body);
//   if (response.statusCode == 200) {
//     final data = json.decode(response.body);
//     final zoneJson = data['data'] as List<dynamic>? ?? [];

//     return zoneJson.map((user) => LevelModel.fromJson(user)).toList();
//   } else {
//     print(json.decode(response.body)['message']);

//     throw Exception(json.decode(response.body)['message']);
//   }
// }
