import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/group_chat_api/group_api.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/group_chat_model.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;



Future<List<GroupChatModel>> getGroupChatMessages(
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
