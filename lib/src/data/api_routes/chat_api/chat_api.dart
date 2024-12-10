import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/chat_model.dart';
import 'package:hef/src/data/models/msg_model.dart';
import 'package:http/http.dart' as http;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

part 'chat_api.g.dart';

// Define a Socket.IO client providerr
final socketIoClientProvider = Provider<SocketIoClient>((ref) {
  return SocketIoClient();
});

// Define a message stream provider
final messageStreamProvider = StreamProvider.autoDispose<MessageModel>((ref) {
  final socketIoClient = ref.read(socketIoClientProvider);
  return socketIoClient.messageStream;
});

class SocketIoClient {
  late IO.Socket _socket;
  final _controller = StreamController<MessageModel>.broadcast();

  SocketIoClient();

  Stream<MessageModel> get messageStream => _controller.stream;

  void connect(String senderId, WidgetRef ref) {
    final uri = 'wss://akcafconnect.com/api/v1/chat?userId=$senderId';

    // Initialize socket.io client
    _socket = IO.io(
      uri,
      IO.OptionBuilder()
          .setTransports(['websocket']) // Use WebSocket transport
          .disableAutoConnect() // Disable auto-connect
          .build(),
    );

    log('Connecting to: $uri');

    // Listen for connection events
    _socket.onConnect((_) {
      log('Connected to: $uri');
    });

    // Listen to messages from the server
    _socket.on('message', (data) {
      log(data.toString());
      print("im inside event listener");
      print('Received message: $data');
      log(' Received message${data.toString()}');
      final messageModel = MessageModel.fromJson(data);

      // Invalidate the fetchChatThreadProvider when a new message is received
      ref.invalidate(fetchChatThreadProvider);

      if (!_controller.isClosed) {
        _controller.add(messageModel);
      }
    });

    // Handle connection errors
    _socket.on('connect_error', (error) {
      print('Connection Error: $error');
      if (!_controller.isClosed) {
        _controller.addError(error);
      }
    });

    // Handle disconnection
    _socket.onDisconnect((_) {
      print('Disconnected from server');
      if (!_controller.isClosed) {
        _controller.close();
      }
    });

    // Connect manually
    _socket.connect();
  }

  void disconnect() {
    _socket.disconnect();
    _socket.dispose(); // To prevent memory leaks
    if (!_controller.isClosed) {
      _controller.close();
    }
  }
}

Future<void> sendChatMessage(
    {required String userId,
    required String content,
    String? feedId,
    bool isGroup = false}) async {
  final url = Uri.parse('$baseUrl/chat/send-message/$userId');
  final headers = {
    'accept': '*/*',
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };
  final body =
      jsonEncode({'content': content, 'isGroup': isGroup, 'feed': feedId});

  try {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Successfully sent the message
      print('Message sent: ${response.body}');
    } else {
      // Handle errors here
      print(json.decode(response.body)['message']);
      print('Failed to send message: ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred: $e');
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
