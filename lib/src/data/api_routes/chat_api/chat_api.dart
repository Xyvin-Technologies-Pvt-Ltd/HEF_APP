import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/group_chat_api/group_api.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/chat_model.dart';
import 'package:hef/src/data/models/group_chat_model.dart';
import 'package:hef/src/data/models/msg_model.dart';
import 'package:http/http.dart' as http;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

part 'chat_api.g.dart';
final socketIoClientProvider = Provider<SocketIoClient>((ref) {
  return SocketIoClient();
});

// Individual Message Stream Provider
final messageStreamProvider = StreamProvider.autoDispose<MessageModel>((ref) {
  final socketIoClient = ref.read(socketIoClientProvider);
  return socketIoClient.messageStream;
});

// Group Message Stream Provider
final groupMessageStreamProvider = StreamProvider.autoDispose<GroupChatModel>((ref) {
  final socketIoClient = ref.read(socketIoClientProvider);
  return socketIoClient.groupMessageStream;
});

class SocketIoClient {
  late IO.Socket _socket;
  
  // Separate controllers for individual & group chat messages
  final _messageController = StreamController<MessageModel>.broadcast();
  final _groupMessageController = StreamController<GroupChatModel>.broadcast();

  SocketIoClient();

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

    _socket.onConnect((_) {
      log('Connected to: $uri');
    });

    // Listen for messages (for both individual and group chat)
    _socket.on('message', (data) {
      log('Received message: $data');
      
      if (data['isGroup'] == true) {
        final groupMessageModel = GroupChatModel.fromJson(data);
        ref.invalidate(getGroupListProvider); // Invalidate group list provider
        if (!_groupMessageController.isClosed) {
          _groupMessageController.add(groupMessageModel);
        }
      } else {
        final messageModel = MessageModel.fromJson(data);
        ref.invalidate(fetchChatThreadProvider); // Invalidate individual chat provider
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

    _socket.onDisconnect((_) {
      log('Disconnected from server');
    });

    _socket.connect();
  }

  void disconnect() {
    _socket.disconnect();
    _socket.dispose(); // Prevent memory leaks

    if (!_messageController.isClosed) _messageController.close();
    if (!_groupMessageController.isClosed) _groupMessageController.close();
  }
}

Future<String> sendChatMessage(
    {required String Id,
    String? content,
    String? productId,

    bool? isGroup=false,
    String? businessId}) async {
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
    "isGroup":isGroup
  });
  log('sending body $body');
  try {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Successfully sent the message
      final jsonResponse = json.decode(response.body);
      print('Message sent: ${response.body}');
      log('Message: ${jsonResponse['data']['_id']}');
      return jsonResponse['data']['_id'];
    } else {
      final jsonResponse = json.decode(response.body);

      print(jsonResponse['message']);
      print('Failed to send message: ${response.statusCode}');
      return '';
    }
  } catch (e) {
    print('Error occurred: $e');
    return '';
  }
}

Future<List<MessageModel>> getChatBetweenUsers(String userId) async {
  final url = Uri.parse('$baseUrl/chat/between-users/$userId');
  final headers = {
    'accept': '*/*',
    'Authorization': 'Bearer $token',
  };

  try {
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      print(response.body);
      List<MessageModel> messages = [];
      log(data.toString());
      for (var item in data) {
        messages.add(MessageModel.fromJson(item));
      }
      return messages;
    } else {
      print('Error: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    // Handle errors
    print('Error: $e');
    return [];
  }
}

@riverpod
Future<List<ChatModel>> fetchChatThread(FetchChatThreadRef ref) async {
  final url = Uri.parse('$baseUrl/chat/get-chats');
  print('Requesting URL: $url');

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final data = json.decode(response.body)['data'];
    log('Response data: $data');
    final List<ChatModel> chats =
        await data.map<ChatModel>((item) => ChatModel.fromJson(item)).toList();
    ;

    return chats;
  } else {
    print('Error: ${json.decode(response.body)['message']}');
    throw Exception(json.decode(response.body)['message']);
  }
}
