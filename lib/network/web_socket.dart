import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:test2/appbar/friend/FriendRequestModel.dart';
import 'package:test2/model/picture.dart';
import 'package:test2/value/global_variable.dart';
import 'package:test2/model/team.dart';
import 'package:test2/model/locationMarker.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:test2/appbar/friend/FriendlistManagement.dart';

class WebSocketService {
  static final WebSocketService _webSocketService = WebSocketService._internal();

  factory WebSocketService() {
    return _webSocketService;
  }

  WebSocketService._internal();

  late WebSocketChannel channel;
  Uri websocketUrl = Uri.parse('ws://220.90.180.89:8080');
  bool _isInitialized = false;
  late StreamSubscription _subscription;
  final _responseController = StreamController<Map<String, dynamic>>.broadcast();
  String buffer = "";
  Timer? _reconnectionTimer;
  final int _reconnectInterval = 5000;

  Stream<Map<String, dynamic>> get responseStream => _responseController.stream;

  void init() {
    if (_isInitialized) return;
    _connect();
    _isInitialized = true;
  }

  void _connect(){
    try{
      channel = IOWebSocketChannel.connect(websocketUrl);
      debugPrint(channel.toString());
      _subscription = channel.stream.listen(
          _handleMessage,
          onError: (error) {
            debugPrint('웹소켓 에러: $error');
            _responseController.add({'error': '웹소켓 에러', 'details': error.toString()});
          },
          onDone: (){
            debugPrint('웹소켓 연결 종료');
            _scheduleReconnection();
          }
      );
    }catch(e){
      debugPrint('웹소켓 연결 에러:$e');
    }
  }

  void _handleMessage(dynamic message) async {
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
  }

  void _scheduleReconnection() {
    _reconnectionTimer?.cancel();
    _reconnectionTimer = Timer(Duration(milliseconds: _reconnectInterval), () {
      debugPrint('재연결 시도 중...');
      _connect();
    });
  }

  Future<Map<String, dynamic>> transmit(dynamic data, String commandType) async {
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
      case 'UpdateImage':
        handleUpdateImage(jsonData);
        break;
      case 'UpdateImageSignal':
        print('서버가 호출함');
        PicManager().syncWithServer();
        break;
      case 'UpdateTeamSignal':
        handleUpdateTeam();
        break;
      case 'TeamLocationUpdate':
        handleUpdateLocation(jsonData);
        break;
      case 'JoinedTeamSignal':
        handleJoinedTeam(jsonData);
        break;
      default:
        debugPrint('$jsonData');
        break;
    }
  }


  void handleJoinTeamRequest(Map<String, dynamic> data) {
    // JoinTeamRequest 처리 로직
    debugPrint('팀 초대 요청 처리: ${data.toString()}');

    final context = GlobalVariable.navigatorKey.currentContext;
    if(context != null){
      showInviteDialog(context, data['teamno'] as int, data['teamName'] as String, data['addid'] as String);
    }else{
      debugPrint('Navigator context is null');
    }
  }

  void handleUpdateImage(Map<String, dynamic> data){
    debugPrint('이미지 업데이트 요청 처리: ${data.toString()}');
    final PicManager _picManager = PicManager();

    if (data.containsKey('img_data')) {
      try {
        PictureEntity newPic = PictureEntity.fromJson(data);
        _picManager.addPicture(newPic).then((_) {
          debugPrint('새 이미지가 성공적으로 추가되었습니다: ${newPic.img_num}');
        }).catchError((error) {
          debugPrint('이미지 추가 중 오류 발생: $error');
        });
      } catch (e) {
        debugPrint('이미지 데이터 파싱 중 오류 발생: $e');
      }
    } else {
      debugPrint('이미지 데이터가 없습니다.');
    }
  }

  void handleUpdateTeam() {
    TeamManager().updateTeam();
  }


  void handleUpdateLocation(Map<String, dynamic> data){
    LocationManager().updateLocation(LocationMarker.fromJson(data));
  }

  void handleJoinedTeam(Map<String, dynamic> data){
    final globalContext = GlobalVariable.globalScaffoldMessengerKey.currentState;

    if(globalContext!=null){
      globalContext.showSnackBar(
        SnackBar(
          content: Text('${data['from_name']}님이 ${data['teamName']}에 초대하였습니다'),
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: '확인',
            onPressed: (){globalContext.hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

void handleFriendRequestReceived(Map<String, dynamic> data) {
    debugPrint('친구 요청 받음: ${data.toString()}');
    final context = GlobalVariable.navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('새로운 친구 요청이 있습니다: ${data['friendName']}')),
      );
    } else {
      debugPrint('Navigator context is null');
    }
  }

  void handleFriendListUpdated(Map<String, dynamic> data) {
    debugPrint('친구 목록 업데이트됨: ${data.toString()}');

    if (data.containsKey('friends') && data['friends'] is List) {
      List<FriendRequest> updatedFriendList = (data['friends'] as List<dynamic>)
          .map((friend) => FriendRequest.fromJson(friend as Map<String, dynamic>))
          .toList();

      // 글로벌 컨텍스트를 통해 Provider에 접근
      final context = GlobalVariable.navigatorKey.currentContext;
      if (context != null) {
        // FriendListManagement 싱글톤 인스턴스를 사용하여 목록 업데이트
        Provider.of<FriendListManagement>(context, listen: false)
            .updateFriendList(updatedFriendList);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('친구 목록이 업데이트되었습니다.')),
        );
      } else {
        debugPrint('Navigator context is null');
      }
    } else {
      debugPrint('친구 목록 데이터가 올바르지 않습니다');
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData, Uint8List? imageBytes) async {
    try {
      final data = {
        'profileData': profileData,
        if (imageBytes != null) 'image': base64Encode(imageBytes),
      };
      return await transmit(data, 'UpdateProfile');
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return {'error': 'Error updating profile', 'details': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updatePhoneNumber(String phoneNumber) async {
    try {
      final data = {'phoneNumber': phoneNumber};
      return await transmit(data, 'UpdatePhoneNumber');
    } catch (e) {
      debugPrint('Error updating phone number: $e');
      return {'error': 'Error updating phone number', 'details': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updatePassword(String newPassword) async {
    try {
      final data = {'newPassword': newPassword};
      return await transmit(data, 'UpdatePassword');
    } catch (e) {
      debugPrint('Error updating password: $e');
      return {'error': 'Error updating password', 'details': e.toString()};
    }
  }

  Future<Map<String, dynamic>> validatePassword(Map<String, dynamic> data) async {
    try {
      return await transmit(data, 'ValidatePassword');
    } catch (e) {
      debugPrint('Error validating password: $e');
      return {'error': 'Error validating password', 'details': e.toString()};
    }
  }

  Future<Map<String, dynamic>> addFriend(String fromId, String toId) async {
    final data = {
      'from_id': fromId,
      'to_id': toId,
    };

    return await transmit(data, 'AddFriend');
  }

  Future<Map<String, dynamic>> addTeamMembers(int teamNo, String teamName, String addIds, String myId) async {
    // 전송할 데이터 리스트 생성
    final data = {
        'teamNo': teamNo,
        'teamName': teamName,
        'addids': addIds,
        'my_id': myId
      };

    // transmit 메서드를 사용하여 데이터와 명령어를 서버에 전송
    return await transmit(data, 'AddTeamMemberS');
  }

  Future<Map<String, dynamic>> refreshAddFriend(String userId) async {
    final data = {
      'id': userId,
    };
    return await transmit(data, 'RefreshAddFriend');
  }

  Future<Map<String, dynamic>> getMyFriend(String userId) async {
    final data = {
      'id': userId,
    };

    // 서버로 데이터 전송하고 응답받기
    final response = await transmit(data, 'GetMyFriend');
    // 만약 response가 이미 Map<String, dynamic>이라면, jsonDecode가 필요하지 않음
    return response;
  }

  Future<Map<String, dynamic>> DeleteFriend(String fromId, String toId) async {
    final data = {
      'from_id': fromId,
      'to_id': toId,
    };
    return await transmit(data, 'DeleteFriend');
  }


  Future<Map<String, dynamic>> acceptFriendRequest(String fromId, String toId, bool areWe) async {
    final data = {
      'from_id': fromId,
      'to_id': toId,
      'are_we': areWe,
    };
    return await transmit(data, 'AcceptFriend');
  }

  Future<Map<String, dynamic>> declineFriendRequest(String fromId, String toId) async {
    final data = {
      'from_id': fromId,
      'to_id': toId,
    };
    return await transmit(data, 'DeclineFriendRequest');
  }

  void addListener(Function(Map<String, dynamic>) listener) {
    _responseController.stream.listen(listener);
  }

  void removeListener(Function(Map<String, dynamic>) listener) {
    // StreamController에서는 직접적인 removeListener 메서드가 없으므로,
    // 실제로 리스너를 제거하는 로직은 필요에 따라 구현해야 합니다.
  }
}
