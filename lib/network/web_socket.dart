import 'package:web_socket_channel/io.dart';

class WebSocketService{
  static final WebSocketService _webSocketService = WebSocketService._internal();

  factory WebSocketService(){
    return _webSocketService;
  }

  WebSocketService._internal();

  IOWebSocketChannel? channel;
  String websocketUrl = 'ws://220.90.180.89:8080';

  void init(){
    channel = IOWebSocketChannel.connect(websocketUrl);
    if(channel!=null){
      channel!.stream.listen(_eventListener).onDone(_reconnect);
    }
  }

  void transmit(dynamic data){
    if(channel!=null){
      channel!.sink.add(data);
    }
  }

  void _eventListener(dynamic event){
    if(event=='message'){

    }
  }

  void _reconnect(){
    if(channel!=null){
      channel!.sink.close();
      init();
    }
  }

  void dispose(){
    channel!.sink.close();
  }
}