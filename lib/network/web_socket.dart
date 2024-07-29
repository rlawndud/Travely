import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static final WebSocketService _webSocketService =
      WebSocketService._internal();

  factory WebSocketService() {
    return _webSocketService;
  }

  WebSocketService._internal();

  late WebSocketChannel channel;
  Uri websocketUrl = Uri.parse('ws://10.101.152.35:8080');
  bool _isInitialized = false;
  late StreamSubscription _subscription;
  final _responseController =
      StreamController<Map<String, dynamic>>.broadcast();

  void init() {
    if (_isInitialized) return;

    channel = IOWebSocketChannel.connect(websocketUrl);
    debugPrint(_isInitialized.toString());

    _subscription = channel.stream.listen((message) {
      try {
        var jsonData = jsonDecode(message);
        if (jsonData is Map<String, dynamic>) {
          _responseController.add(jsonData);
        } else {
          _responseController.add({'error': 'Unexpected response format', 'data': jsonData});
        }
      } catch (e) {
        debugPrint('Error parsing WebSocket message: $e');
        _responseController.add({'error': 'Invalid JSON data', 'raw': message});
      }
    },
      onError: (error) {
        debugPrint('WebSocket error: $error');
        _responseController.add({'error': 'WebSocket error', 'details': error.toString()});
      },
    );
    _isInitialized = true;
  }

  Future<Map<String, dynamic>> transmit(
      dynamic data, String commandType) async {
    dynamic command_type = {'command': commandType};
    dynamic signal = {'signal': '@'};
    List<Map<String, dynamic>> message = [command_type, data, signal];
    String jsonData = jsonEncode(message);
    channel.sink.add(jsonData);

    /*var response = await _webSocketService.channel.stream.first;
    var jsonResponse = jsonDecode(response);*/

    return await _responseController.stream.first;
  }

  Future<dynamic> receive() async {}

  void dispose() {
    _subscription.cancel();
    _responseController.close();
    channel.sink.close();
  }
}
