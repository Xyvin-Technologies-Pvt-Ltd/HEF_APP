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

// Define a Socket.IO client providerr
final socketIoClientProvider = Provider<SocketIoClient>((ref) {
  return SocketIoClient();
});

// Define a message stream provider
final groupMessageStreamProvider =
    StreamProvider.autoDispose<GroupChatModel>((ref) {
  final socketIoClient = ref.read(socketIoClientProvider);
  return socketIoClient.messageStream;
});

class SocketIoClient {
  late IO.Socket _socket;
  final _controller = StreamController<GroupChatModel>.broadcast();

  SocketIoClient();

  Stream<GroupChatModel> get messageStream => _controller.stream;

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
      final messageModel = GroupChatModel.fromJson(data);

      // Invalidate the fetchChatThreadProvider when a new message is received
      ref.invalidate(getGroupListProvider);

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
