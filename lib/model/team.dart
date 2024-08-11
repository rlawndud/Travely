import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test2/model/picture.dart';
import 'package:test2/util/globalUI.dart';
import 'package:test2/value/color.dart';

import '../network/web_socket.dart';

class Team {
  int teamNo;
  String teamName;
  String leaderId;

  Team(this.teamNo, this.teamName, this.leaderId);

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      json['teamno'] as int,
      json['teamName'] as String,
      json['LeaderID'] as String,
    );
  }

  // Member 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'teamno': teamNo,
      'teamName': teamName,
      'LeaderID': leaderId,
    };
  }
}

class TeamEntity{
  int teamNo;
  String teamName;
  List<Map<String,dynamic>> members;

  TeamEntity(this.teamNo,this.teamName,this.members);

  factory TeamEntity.fromJson(Map<String, dynamic> json){
    List<dynamic> members = json['teammems'];
    List<Map<String,dynamic>> resultMembers = [];
    for(var member in members){
      String id = member[0];
      String name = member[1];
      Map<String, dynamic> mem = {
        'id':id,
        'name':name,
      };
      resultMembers.add(mem);
    }
    return TeamEntity(
      json['teamNo'] as int,
      json['teamName'] as String,
      resultMembers,
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'teamNo': teamNo,
      'teamName': teamName,
      'member': members,
    };
  }

  @override
  String toString() {
    return 'teamNo: $teamNo, teamName: $teamName, member: $members';
  }
}

class TeamManager with ChangeNotifier {
  final WebSocketService _webSocketService = WebSocketService();
  static final TeamManager _instance = TeamManager._internal();
  Map<String, List<TeamEntity>> _userTeams = {};
  static String _curTeam = '';
  static String _currentUserId='';
  bool _isInitialized = false;

  TeamManager._internal();

  // 싱글톤 객체 반환
  factory TeamManager(){
    return _instance;
  }

  Future<void> initialize(String userId) async {
    if (!_isInitialized || _currentUserId != userId) {
      _currentUserId = userId;
      await loadTeam();
      await loadCurTeam();
      print('TeamInit : $currentTeam');
      _isInitialized = true;
    }
  }

  List<TeamEntity> getTeamList() => _userTeams[_currentUserId] ?? [];
  List<int> getTeamNoList(){
    List<int> teamNoList = [];
    for(TeamEntity team in getTeamList()){
      teamNoList.add(team.teamNo);
    }
    print(teamNoList);
    return teamNoList;
  }
  String get currentTeam => _curTeam;

  set currentTeam(String teamName) {
    _curTeam = teamName;
    saveCurTeam(_currentUserId, teamName);
    notifyListeners();
  }

  int? getTeamNoByTeamName(String teamName){
    for(var team in _userTeams[_currentUserId]!){
      if(team.teamName == teamName){
        return team.teamNo;
      }
    }
    return null;
  }

  String? getTeamNameByTeamNo(int teamNo){
    for(var team in _userTeams[_currentUserId]!){
      if(team.teamNo==teamNo){
        return team.teamName;
      }
    }
    return null;
  }

  Future<void> saveCurTeam(String userId, String currentTeam) async{
    final Directory directory = await getApplicationDocumentsDirectory();
    final String dirPath = '${directory.path}/$userId';
    final Directory dir = Directory(dirPath);

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final File fileCur = File('$dirPath/currentTeam.json');
    final curTeamdata = {
      'currentTeam': currentTeam,
    };
    _curTeam = currentTeam;
    await fileCur.writeAsString(json.encode(curTeamdata));
  }

  Future<void> loadCurTeam() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/$_currentUserId/currentTeam.json');
    if (await file.exists()) {
      try {
        final String contents = await file.readAsString();
        final Map<String, dynamic> data = json.decode(contents);
        _curTeam = data['currentTeam'] as String;
      } catch (e) {
        print('current team 로딩중 문제발생 : $e');
        _curTeam = ''; // 파일 읽기 실패 시 빈 문자열로 설정
      }
    } else {
      _curTeam = ''; // 파일이 없을 경우 빈 문자열로 설정
    }
  }

  Future<void> loadTeam() async {
    Map<String, dynamic> data = {'id': _currentUserId};
    var jsonResponse = await _webSocketService.transmit(data, 'GetMyTeamInfo');
    _userTeams[_currentUserId] = [];
    if (jsonResponse.containsKey('teams')) {
      List<dynamic> teamsData = jsonResponse['teams'];
      for (var team in teamsData) {
        TeamEntity te = TeamEntity.fromJson(team);
        _userTeams[_currentUserId]!.add(te);
      }
      notifyListeners();
    }
  }

  Future<void> updateTeam() async {
    Map<String, dynamic> data = {'id': _currentUserId};
    await _webSocketService.transmit(data, 'GetMyTeamInfo');
    _userTeams[_currentUserId] = [];

    var jsonResponse = await _webSocketService.responseStream.firstWhere(
        (response) => response.containsKey('teams'),
      orElse: () => {'error':''}
    );

    if (jsonResponse.containsKey('teams')) {
      List<dynamic> teamsData = jsonResponse['teams'];
      for (var team in teamsData) {
        TeamEntity te = TeamEntity.fromJson(team);
        _userTeams[_currentUserId]!.add(te);
      }
      notifyListeners();
    } else {
      print('error');
    }
  }

  // 팀가입 요청
  Future<Map<String, dynamic>> inviteTeamMember(String teamName, String addMember) async {
    Map<String, dynamic> data = {
      'teamNo': getTeamNoByTeamName(teamName),
      'teamName': teamName,
      'addid': addMember,
    };
    return await _webSocketService.transmit(data, 'AddTeamMember');
  }

  // 팀가입 요청 응답
  Future<Map<String, dynamic>> acceptTeamMember(
      int teamNo, String teamName, String memberId, bool isExcept) async {
    Map<String, dynamic> data = {
      'teamno': teamNo,
      'teamName': teamName,
      'addid': memberId,
      'isexcept': isExcept,
    };
    return await _webSocketService.transmit(data, 'AcceptTeamRequest');
  }

  Future<void> createTeamFolder(String folderName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = '${directory.path}/$folderName';
    final Directory folder = Directory(path);

    if (!await folder.exists()) {
      await folder.create(recursive: true);
      print('폴더 생성: $path');
    } else {
      print('이미 생성된 폴더: $path');
    }
  }

  Future<String> deleteTeam(String teamName) async{
    Map<String, dynamic> data = {
      'team_no': getTeamNoByTeamName(teamName),
      'id': _currentUserId,
    };
    var response = await _webSocketService.transmit(data, 'DeleteTeam');
    if(response.containsKey('result')){
      if(response['result']=='True'){
        //여기서 로컬폴더도 삭제해야 함.
        PicManager().deleteTeamPictures(teamName);
        loadTeam();
      }
      return response['result'];
    }else{
      return 'error';
    }
  }

  Future<void> clearCurrentUserData() async {
    _userTeams.remove(_currentUserId);
    _curTeam = '';
    _isInitialized = false;
    notifyListeners();
  }
}


void showInviteDialog(BuildContext context, int teamNo, String teamName, String memberId) {
  TeamManager _teamManager = new TeamManager();
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('팀 초대'),
          content: Text('$memberId 님을 $teamName 팀에 초대하였습니다. 수락하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                // 초대 수락 시 팀 멤버 목록에 추가
                await _teamManager.acceptTeamMember(teamNo, teamName, memberId, true);
                _teamManager.createTeamFolder(teamName);
                PicManager().getNewTeamPictures(teamNo);
              },
              child: const Text(
                '수락',
                style: TextStyle(
                  color: mainColor,
                ),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: mainColor,
              ),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await _teamManager.acceptTeamMember(teamNo, teamName, memberId, false);
                showSnackBar('$teamName 팀의 초대를 거절하였습니다', null);
              },
              child: const Text(
                '거절',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      });
}