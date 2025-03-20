import 'dart:convert';
import 'dart:developer';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/group_info.dart';
import 'package:hef/src/data/models/group_model.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_api.g.dart';


@riverpod
Future<List<GroupModel>> getGroupList(
  GetGroupListRef ref,
) async {
  final response = await http.get(
    Uri.parse('$baseUrl/chat/list-group'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final groupsJson = data['data'] as List<dynamic>? ?? [];

    return groupsJson.map((user) => GroupModel.fromJson(user)).toList();
  } else {
    final data = json.decode(response.body);
    log(data['message']);
    throw Exception('Failed to load Groups');
  }
}

@riverpod
Future<GroupInfoModel> fetchGroupInfo(FetchGroupInfoRef ref,
    {required String id}) async {
  final url = Uri.parse('$baseUrl/chat/group-details/$id');
  print('Requesting URL: $url');
  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );
  print('hello');
  log(response.body);
  if (response.statusCode == 200) {
    final dynamic data = json.decode(response.body)['data'];

    return GroupInfoModel.fromJson(data);
  } else {
    print(json.decode(response.body)['message']);

    throw Exception(json.decode(response.body)['message']);
  }
}
