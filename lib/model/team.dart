import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
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
}

class TeamManager {
  final WebSocketService _webSocketService = WebSocketService();
  static final TeamManager _instance = TeamManager._internal();
  static List<TeamEntity> _teams = [];
  static String curTeam = '';

  TeamManager._internal();

  // 싱글톤 객체 반환
  factory TeamManager(){
    return _instance;
  }

  List<TeamEntity> getTeamList(){
    return _teams;
  }


  int? getTeamNoByTeamName(String teamName){
    for(var team in _teams){
      if(team.teamName == teamName){
        return team.teamNo;
      }
    }
    return null;
  }

  Future<void> saveTeams(String userId) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/${userId}/teams.json');
    final data = {
      'teams': _teams.map((team) => team.toJson()).toList(),
    };


    await file.writeAsString(json.encode(data));
  }

  Future<void> saveCurTeams(String userId, String _currentTeam) async{
    final Directory directory = await getApplicationDocumentsDirectory();
    final File fileCur = File('${directory.path}/${userId}/currentTeam.json');
    final curTeamdata = {
      'currentTeam': _currentTeam,
    };
    curTeam = _currentTeam;
    await fileCur.writeAsString(json.encode(curTeamdata));
  }

  Future<void> loadCurTeamFromFile(String userId, ) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/${userId}/currentTeam.json');
    if (await file.exists()) {
      final String contents = await file.readAsString();
      final Map<String, dynamic> data = json.decode(contents);
      curTeam = data['currentTeam'] as String;
    }
  }
  // 팀 정보를 로드하는 메서드
  Future<void> loadTeamsFromFile() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/teams.json');
    if (await file.exists()) {
      final String contents = await file.readAsString();
      final Map<String, dynamic> data = json.decode(contents);
      _teams = List<TeamEntity>.from(
        (data['teams'] as List<dynamic>).map((item) => TeamEntity.fromJson(item)),
      );
    }
  }

  Future<void> loadTeam(String userId) async {
    //await loadTeamsFromFile(); // 파일에서 팀 정보를 먼저 로드
    Map<String, dynamic> data = {'id': userId};
    var jsonResponse = await _webSocketService.transmit(data, 'GetMyTeamInfo');

    if (jsonResponse.containsKey('teams')) {
      List<dynamic> teamsData = jsonResponse['teams'];
      for (var team in teamsData) {
        TeamEntity te = TeamEntity.fromJson(team);
        _teams.add(te);
      }
      await saveTeams(userId); // 서버에서 로드한 팀 정보를 파일에 저장
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
}

void showInviteDialog(BuildContext context, int teamNo, String teamName, String memberId) {
  TeamManager tDB = new TeamManager();
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
                await tDB.acceptTeamMember(teamNo, teamName, memberId, true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$teamName 팀의 초대를 수락하였습니다')),
                );
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
                await tDB.acceptTeamMember(teamNo, teamName, memberId, false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$teamName 팀의 초대를 거절하였습니다')),
                );
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
