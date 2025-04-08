import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/group_chat_model.dart';
import 'package:hef/src/data/models/group_info.dart';
import 'package:hef/src/data/models/group_model.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_api.g.dart';

class GroupApiService {
  const GroupApiService();

  Future<List<GroupModel>> getGroupList() async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/list-group'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final groupsJson = data['data'] as List<dynamic>? ?? [];
      return groupsJson.map((e) => GroupModel.fromJson(e)).toList();
    } else {
      final error = json.decode(response.body);
      log(error['message']);
      throw Exception('Failed to load groups');
    }
  }


static Future<List<GroupChatModel>> getGroupChatMessages(
    {required String groupId}) async {
  log('group: $groupId');
  final url = Uri.parse('$baseUrl/chat/group-message/$groupId');
  final headers = {
    'accept': '*/*',
    'Authorization': 'Bearer $token',
  };

  try {
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      print(response.body);
      List<GroupChatModel> messages = [];
      log(data.toString());
      for (var item in data) {
        messages.add(GroupChatModel.fromJson(item));
      }
      return messages;
    } else {
      print('Error: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error: $e');
    return [];
  }
}

  Future<GroupInfoModel> fetchGroupInfo(String id) async {
    final url = Uri.parse('$baseUrl/chat/group-details/$id');
    log('Requesting URL: $url');

    final response = await http.get(url, headers: _headers());
    log(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return GroupInfoModel.fromJson(data);
    } else {
      final error = json.decode(response.body)['message'];
      log(error);
      throw Exception(error);
    }
  }

  Map<String, String> _headers() => {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };
}


@riverpod
GroupApiService groupApiService(Ref ref) {
  return const GroupApiService();
}

@riverpod
Future<List<GroupModel>> getGroupList(Ref ref) {
  final api = ref.watch(groupApiServiceProvider);
  return api.getGroupList();
}

@riverpod
Future<GroupInfoModel> fetchGroupInfo(Ref ref, {required String id}) {
  final api = ref.watch(groupApiServiceProvider);
  return api.fetchGroupInfo(id);
}
