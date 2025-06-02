import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:hef/src/data/api_routes/group_chat_api/group_api.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/chat_model.dart';
import 'package:hef/src/data/models/group_chat_model.dart';
import 'package:hef/src/data/models/msg_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_api.g.dart';


class SocketIoClientService {
  late IO.Socket _socket;

  final _messageController = StreamController<MessageModel>.broadcast();
  final _groupMessageController = StreamController<GroupChatModel>.broadcast();

  Stream<MessageModel> get messageStream => _messageController.stream;
  Stream<GroupChatModel> get groupMessageStream => _groupMessageController.stream;

  void connect(String senderId, WidgetRef ref) {
    final uri = 'wss://api.hefconnect.in/api/v1/chat?userId=$senderId';

    _socket = IO.io(
      uri,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    log('Connecting to: $uri');

    _socket.onConnect((_) => log('Connected to: $uri'));

    _socket.on('message', (data) {
      log('Received message: $data');

      if (data['isGroup'] == true) {
        final groupMessageModel = GroupChatModel.fromJson(data);
        ref.invalidate(getGroupListProvider);
        if (!_groupMessageController.isClosed) {
          _groupMessageController.add(groupMessageModel);
        }
      } else {
        final messageModel = MessageModel.fromJson(data);
        ref.invalidate(fetchChatThreadProvider);
        if (!_messageController.isClosed) {
          _messageController.add(messageModel);
        }
      }
    });

    _socket.on('connect_error', (error) {
      log('Connection Error: $error');
      if (!_messageController.isClosed) _messageController.addError(error);
      if (!_groupMessageController.isClosed) _groupMessageController.addError(error);
    });

    _socket.onDisconnect((_) => log('Disconnected from server'));

    _socket.connect();
  }

  void disconnect() {
    _socket.disconnect();
    _socket.dispose();
    if (!_messageController.isClosed) _messageController.close();
    if (!_groupMessageController.isClosed) _groupMessageController.close();
  }
}

final socketIoClientProvider = Provider<SocketIoClientService>((ref) {
  return SocketIoClientService();
});


final messageStreamProvider = StreamProvider.autoDispose<MessageModel>((ref) {
  final socketService = ref.read(socketIoClientProvider);
  return socketService.messageStream;
});

final groupMessageStreamProvider = StreamProvider.autoDispose<GroupChatModel>((ref) {
  final socketService = ref.read(socketIoClientProvider);
  return socketService.groupMessageStream;
});


class ChatApiService {
  static Future<String> sendChatMessage({
    required String Id,
    String? content,
    String? productId,
    bool isGroup = false,
    String? businessId,
  }) async {
    final url = Uri.parse('$baseUrl/chat/send-message/$Id');
    final headers = {
      'accept': '*/*',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      if (content != null) 'content': content,
      if (productId != null) 'product': productId,
      if (businessId != null) 'feed': businessId,
      'isGroup': isGroup,
    });

    log('Sending body $body');

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        log('Message sent: ${jsonResponse['data']['_id']}');
        return jsonResponse['data']['_id'];
      } else {
        final jsonResponse = json.decode(response.body);
        log('Failed to send message: ${jsonResponse['message']}');
        return '';
      }
    } catch (e) {
      log('Error occurred: $e');
      return '';
    }
  }

  static Future<List<MessageModel>> getChatBetweenUsers(String userId) async {
    final url = Uri.parse('$baseUrl/chat/between-users/$userId');
    final headers = {
      'accept': '*/*',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((item) => MessageModel.fromJson(item)).toList();
      } else {
        log('Error fetching chat: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Exception: $e');
      return [];
    }
  }

  static Future<List<ChatModel>> fetchChatThreads() async {
    final url = Uri.parse('$baseUrl/chat/get-chats');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body)['data'] as List;
        return data.map((item) => ChatModel.fromJson(item)).toList();
      } else {
        throw Exception(json.decode(response.body)['message']);
      }
    } catch (e) {
      log('Error fetching chat threads: $e');
      throw Exception('Failed to load chat threads');
    }
  }
}


@riverpod
Future<List<ChatModel>> fetchChatThread(FetchChatThreadRef ref) async {
  return ChatApiService.fetchChatThreads();
}
