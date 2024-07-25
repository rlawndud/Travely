import 'dart:convert';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService{
  static final WebSocketService _webSocketService = WebSocketService._internal();

  factory WebSocketService(){
    return _webSocketService;
  }

  WebSocketService._internal();

  late WebSocketChannel channel;
  Uri websocketUrl = Uri.parse('ws://220.90.180.89:8080');
  bool _isInitialized = false;

  void init(){
    if (_isInitialized) return;

    channel = IOWebSocketChannel.connect(websocketUrl);
/*    final signal = {'signal': '@'};
    final command = {'command':'ping'};
    List<Map<String,String>> data = [command,signal];
    String jsonData = jsonEncode(data);
    print(jsonData);
    channel.sink.add(jsonData);*/
    _isInitialized = true;
  }

  Future<Map<String, dynamic>> transmit(dynamic data, String commandType) async {

    dynamic command_type = {'command': commandType};
    dynamic signal = {'signal': '@'};
    List<Map<String,dynamic>> message = [command_type,data,signal];
    String jsonData = jsonEncode(message);
    channel.sink.add(jsonData);

    var response = await _webSocketService.channel.stream.first;
    var jsonResponse = jsonDecode(response);
    return jsonResponse;
  }

  Future<dynamic> receive() async{

  }


  void dispose(){
    channel.sink.close();
  }
}