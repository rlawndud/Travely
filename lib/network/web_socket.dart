import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:test2/model/team.dart';
import 'package:test2/team_page.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static final WebSocketService _webSocketService =
      WebSocketService._internal();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  factory WebSocketService() {
    return _webSocketService;
  }

  WebSocketService._internal();

  late WebSocketChannel channel;
  Uri websocketUrl = Uri.parse('ws://192.168.0.45:8080');
  bool _isInitialized = false;
  late StreamSubscription _subscription;
  final _responseController =
      StreamController<Map<String, dynamic>>.broadcast();
  String buffer = "";

  void init() {
    if (_isInitialized) return;

    channel = IOWebSocketChannel.connect(websocketUrl);
    debugPrint(channel.toString());
    _subscription = channel.stream.listen((message) {
      try {
        buffer += message;
        if (buffer.contains("@"))
        {
          int endIndex = buffer.indexOf('@');
          String jsonMessage = buffer.substring(0, endIndex);
          buffer = "";

          var jsonData = jsonDecode(jsonMessage);

          //형식 확인용
          debugPrint('message: ${message.toString()}');
          debugPrint('jsonData: ${jsonData.toString()}');

          if (jsonData is Map<String, dynamic>) {
            if(jsonData.containsKey('command')){
              handleMessage(jsonData);
            }
            _responseController.add(jsonData);
          } else {
            _responseController.add({'error': 'Unexpected response format', 'data': jsonData});
          }
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

    return await _responseController.stream.first;
  }

  Future<dynamic> receive() async {}

  void dispose() {
    _subscription.cancel();
    _responseController.close();
    channel.sink.close();
  }

  void handleMessage(Map<String, dynamic> jsonData) {
    switch (jsonData['command']) {
      case 'JoinTeamRequest':
        handleJoinTeamRequest(jsonData);
        break;
      default:
        debugPrint('처리 안함~ $jsonData');
        break;
    }
  }
  void handleJoinTeamRequest(Map<String, dynamic> data) {
    // JoinTeamRequest 처리 로직
    debugPrint('팀 초대 요청 처리: ${data.toString()}');

    final context = navigatorKey.currentContext;
    if(context != null){
      showInviteDialog(context, data['teamno'] as int, data['teamName'] as String, data['addid'] as String);
    }else{
      debugPrint('Navigator context is null');
    }
  }
}
