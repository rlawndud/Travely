import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test2/model/team.dart';
import 'package:test2/network/web_socket.dart';

class PictureEntity {
  int img_num;
  String user_id;
  String img_data;
  int team_num;
  List<String> pre_face;
  String pre_background;

  PictureEntity(this.img_num, this.user_id, this.img_data, this.team_num, this.pre_face, this.pre_background);

  factory PictureEntity.fromJson(Map<String, dynamic> json) {
    var preFaceData = json['pre_face'];
    List<String> preFaceList;

    if (preFaceData is String) {
      if(preFaceData.contains('#')){
        preFaceList = preFaceData.split('#').where((name) => name.isNotEmpty).toList();
      }else{
        preFaceList = preFaceData.isEmpty ? [] : [preFaceData];
      }
    } else {
      preFaceList = [];
    }

    return PictureEntity(
      json['img_num'] as int,
      json['id'] as String,
      json['img_data'] as String,
      json['teamno'] as int,
      preFaceList,
      json['pre_background'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'img_num': img_num,
      'id': user_id,
      'img_data': img_data,
      'teamno': team_num,
      'pre_face': jsonEncode(pre_face),
      'pre_background': pre_background,
    };
  }

  String printPredict() {
    return '사진 속 인물: $pre_face\n사진 배경: $pre_background';
  }

  @override
  String toString() {
    return 'img_num: $img_num, teamno: $team_num';
  }
}

class PicManager with ChangeNotifier {
  static final PicManager _instance = PicManager._internal();
  final WebSocketService _webSocketService = WebSocketService();
  final Map<String, List<PictureEntity>> _userPictures = {};
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
      await loadPictures();
      await syncWithServer();
      _isInitialized = true;
    }
  }

  List<PictureEntity> getPictureList() => _userPictures[_currentUserId] ?? [];
  Stream<PictureEntity> get imageStream => _imageStreamController.stream;
  String getCurrentId() => _currentUserId;

  Future<void> addPicture(PictureEntity picture) async {
    _userPictures[_currentUserId] ??= [];
    _userPictures[_currentUserId]!.add(picture);
    _imageStreamController.add(picture);
    await Future.delayed(const Duration(milliseconds: 10));
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

      for (var item in data['pictures']) {
        PictureEntity pic = PictureEntity.fromJson(item);
        _userPictures[_currentUserId]!.add(pic);
        _imageStreamController.add(pic);
        await Future.delayed(const Duration(milliseconds: 10));
      }
    } else {
      _userPictures[_currentUserId] = [];
    }
  }

  Future<void> syncWithServer() async {
    int? lastImageNum = _userPictures[_currentUserId]?.isEmpty ?? true
        ? null
        : _userPictures[_currentUserId]!.last.img_num;

    Map<String, dynamic> data = {
      'team': TeamManager().getTeamNoList(),
      'last_img_num': lastImageNum,
    };

    var response = await _webSocketService.transmit(data, 'GetAllImage');

    if (response.containsKey('result')) {
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
