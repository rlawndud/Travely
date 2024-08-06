import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test2/model/team.dart';
import 'package:test2/network/web_socket.dart';

class Picture{
  int? img_num;
  String user_id;
  String img_data;

  Picture(this.img_num, this.user_id, this.img_data);

  factory Picture.fromJson(Map<String, dynamic> json) {
    //String > XFile으로 변환하는 코드 추가하기

    return Picture(
      json['img_num'] as int?,
      json['id'] as String,
      json['img_data'] as String,
    );
  }

  // Member 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    //XFile > String으로 변환하는 코드 추가하기
    return {
      'img_num':img_num,
      'id': user_id,
      'img_data': img_data,
    };
  }
  @override
  String toString() {
    return 'img_num: $img_num, user_id: $user_id, img_data: ${img_data}';
  }
}

class PictureEntity{
  int img_num;
  String user_id;
  String img_data;
  int team_num;
  String pre_face;
  String pre_background;


  PictureEntity(this.img_num, this.user_id, this.img_data, this.team_num, this.pre_face, this.pre_background);

  factory PictureEntity.fromJson(Map<String, dynamic> json){
    return PictureEntity(
      json['img_num'] as int,
      json['id'] as String,
      json['img_data'] as String,
      json['teamno'] as int,
      json['pre_face'] as String,
      json['pre_background'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'img_num': img_num,
      'id': user_id,
      'img_data': img_data,
      'teamno': team_num,
      'pre_face': pre_face,
      'pre_background': pre_background,
    };
  }

  String printPredict() {
    return ('사진 속 인물 : $pre_face\n 사진 배경 : $pre_background');
  }

  @override
  String toString() {
    return ('img_num: $img_num, teamno: $img_num');
  }
}

class PicManager with ChangeNotifier {
  static final PicManager _instance = PicManager._internal();
  final WebSocketService _webSocketService = WebSocketService();
  Map<String, List<PictureEntity>> _userPictures = {};
  static String _currentUserId = '';
  bool _isInitialized = false;
  final _imageStreamController = StreamController<PictureEntity>.broadcast();

  PicManager._internal();

  factory PicManager() {
    return _instance;
  }

  Future<void> initialize(String userId) async {
    if (!_isInitialized || _currentUserId != userId) {
      _currentUserId = userId;
      await loadPictures(); //로컬 이미지데이터 로드
      await syncWithServer(); //서버 이미지데이터 로드
      _isInitialized = true;
    }
  }

  List<PictureEntity> getPictureList() => _userPictures[_currentUserId] ?? [];
  Stream<PictureEntity> get imageStream => _imageStreamController.stream;

  Future<void> addPicture(PictureEntity picture) async {
    _userPictures[_currentUserId] ??= [];
    _userPictures[_currentUserId]!.add(picture);
    _imageStreamController.add(picture); // 스트림으로 이미지 전송
    await Future.delayed(Duration(milliseconds: 10)); // UI 업데이트를 위한 짧은 딜레이
    await savePictures();
    notifyListeners();
  }

  Future<void> savePictures() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String dirPath = '${directory.path}/$_currentUserId';
    final Directory dir = Directory(dirPath);

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final File file = File('$dirPath/pictures.json');
    final data = {
      'pictures': _userPictures[_currentUserId]?.map((pic) => pic.toJson()).toList(),
    };
    await file.writeAsString(json.encode(data));
  }

  Future<void> loadPictures() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/$_currentUserId/pictures.json');
    if (await file.exists()) {
      final String contents = await file.readAsString();
      final Map<String, dynamic> data = json.decode(contents);
      _userPictures[_currentUserId] = [];

      // 비동기적으로 이미지 로드
      for (var item in data['pictures']) {
        PictureEntity pic = PictureEntity.fromJson(item);
        _userPictures[_currentUserId]!.add(pic);
        _imageStreamController.add(pic); // 스트림으로 이미지 전송
        await Future.delayed(Duration(milliseconds: 10)); // UI 업데이트를 위한 짧은 딜레이
      }
    } else {
      _userPictures[_currentUserId] = [];
    }
    print(_userPictures);
  }

  // 서버와 이미지데이터 동기화
  Future<void> syncWithServer() async {
    int? lastImageNum = _userPictures[_currentUserId]?.isEmpty ?? true
        ? null
        : _userPictures[_currentUserId]!.last.img_num;

    Map<String, dynamic> data = {
      'team': TeamManager().getTeamNoList(),
      'last_img_num': lastImageNum,
    };
    
    var response = await _webSocketService.transmit(data, 'GetAllImage');
    
    if(response.containsKey('result')){
      print('현재 업데이트할 이미지가 없음');
    }
  }

  Future<void> uploadImage(File imageFile, int teamNo) async {
    String base64Image = base64Encode(imageFile.readAsBytesSync());
    Map<String, dynamic> data = {
      'id': _currentUserId,
      'teamno': teamNo,
      'image': base64Image,
    };

    var response = await _webSocketService.transmit(data, 'AddImage');
    if (response.containsKey('new_image')) {
      PictureEntity newPic = PictureEntity.fromJson(response['new_image']);
      await addPicture(newPic);
    }
  }

  Future<void> clearCurrentUserData() async {
    _userPictures.remove(_currentUserId);
    _isInitialized = false;
    notifyListeners();
  }

}