import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:travley/model/team.dart';
import 'package:travley/network/web_socket.dart';

class PictureEntity {
  int img_num;
  String user_id;
  String img_data;
  int team_num;
  List<String> pre_face;
  String pre_background;
  String pre_caption;
  double latitude;
  double longitude;
  String location;
  String date;
  String season;


  PictureEntity(this.img_num, this.user_id, this.img_data, this.team_num, this.pre_face, this.pre_background, this.pre_caption,
      this.latitude, this.longitude, this.location, this.date, this.season);

  factory PictureEntity.fromJson(Map<String, dynamic> json) {
    var preFaceData = json['pre_face'];
    List<String> preFaceList=[];
    // print('fromJson(1) : ${json['date']}, $preFaceData');

    if (preFaceData is String) {
      preFaceList = preFaceData.split('#').where((name) => name.isNotEmpty).toList();
    } else if (preFaceData is List) {
      for(var face in preFaceData){
        preFaceList.add(face);
      }
    } else {
      preFaceList = [];
    }
    // print('fromJson(2) : ${json['date']}, $preFaceList');

    return PictureEntity(
      json['img_num'] as int,
      json['id'] as String,
      json['img_data'] as String,
      json['teamno'] as int,
      preFaceList,
      json['pre_background'] as String,
      json['pre_caption'] as String,
      json['latitude'] as double,
      json['longitude'] as double,
      json['location'] as String,
      json['date'] as String,
      json['season'] as String,
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
      'pre_caption': pre_caption,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'date': date,
      'season':season,
    };
  }

  String printPredict() {
    return '촬영날짜: $date\n장소: $location\n촬영자: $user_id\n사진 속 인물: $pre_face\n사진 배경: $pre_background\n요약문장: $pre_caption';
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
    await Future.delayed(Duration(milliseconds: 10));
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
        // print('이미지 불러오기(로컬) : ${pic.date} : , ${pic.pre_face}');
        _userPictures[_currentUserId]!.add(pic);
        _imageStreamController.add(pic);
        await Future.delayed(Duration(milliseconds: 10));
      }
    } else {
      _userPictures[_currentUserId] = [];
    }
  }

  Future<void> deleteTeamPictures(String teamName) async{
    int? teamNo = TeamManager().getTeamNoByTeamName(teamName);
    _userPictures[_currentUserId] = _userPictures[_currentUserId]?.where((pic)=>pic.team_num != teamNo).toList()??[];
    await savePictures();
    notifyListeners();
  }

  Future<void> syncWithServer() async {
    int? lastImageNum = _userPictures[_currentUserId]?.isEmpty ?? true ? null
        : _userPictures[_currentUserId]!
        .map((pic)=>pic.img_num)
        .reduce((max, current) => max > current? max:current);

    Map<String, dynamic> data = {
      'team': TeamManager().getTeamNoList(),
      'last_img_num': lastImageNum,
    };

    var response = await _webSocketService.transmit(data, 'GetAllImage');

    if (response.containsKey('result')) {
      print('현재 업데이트할 이미지가 없음');
    }
  }

  Future<void> getNewTeamPictures(int teamNo) async{
    Map<String, dynamic> data = {
      'team': teamNo,
      'last_img_num': null,
    };
    await _webSocketService.transmit(data, 'GetAllImage');
  }

  Future<void> clearCurrentUserData() async {
    _userPictures.remove(_currentUserId);
    _isInitialized = false;
    notifyListeners();
  }
}