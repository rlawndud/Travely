import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../network/web_socket.dart';

class TeamEntity {
  int teamNo;
  String teamName;
  List<Map<String, dynamic>> members;

  TeamEntity(this.teamNo, this.teamName, this.members);

  factory TeamEntity.fromJson(Map<String, dynamic> json) {
    List<dynamic> members = json['teammems'];
    List<Map<String, dynamic>> resultMembers = [];
    for (var member in members) {
      String id = member[0];
      String name = member[1];
      Map<String, dynamic> mem = {
        'id': id,
        'name': name,
      };
      resultMembers.add(mem);
    }
    return TeamEntity(
      json['teamNo'] as int,
      json['teamName'] as String,
      resultMembers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamNo': teamNo,
      'teamName': teamName,
      'member': members,
    };
  }
}

class TeamManager {
  static final TeamManager _instance = TeamManager._internal();
  List<TeamEntity> _teams = [];
  static String curTeam = '';

  factory TeamManager() {
    return _instance;
  }

  TeamManager._internal();

  List<TeamEntity> getTeamList() {
    return _teams;
  }

  void setTeamList(List<TeamEntity> teams) {
    _teams = teams;
  }

  void addTeam(TeamEntity team) {
    if (!_teams.any((t) => t.teamNo == team.teamNo)) {
      _teams.add(team);
    }
  }

  int? getTeamNoByTeamName(String teamName) {
    for (var team in _teams) {
      if (team.teamName == teamName) {
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

  Future<void> saveCurTeams(String userId, String _currentTeam) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File fileCur = File('${directory.path}/${userId}/currentTeam.json');
    final curTeamdata = {
      'currentTeam': _currentTeam,
    };
    curTeam = _currentTeam;
    await fileCur.writeAsString(json.encode(curTeamdata));
  }

  Future<void> loadCurTeamFromFile(String userId) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/${userId}/currentTeam.json');
    if (await file.exists()) {
      final String contents = await file.readAsString();
      final Map<String, dynamic> data = json.decode(contents);
      curTeam = data['currentTeam'] as String;
    }
  }

  Future<void> loadTeam(String userId) async {
    Map<String, dynamic> data = {'id': userId};
    var jsonResponse = await WebSocketService().transmit(data, 'GetMyTeamInfo');

    if (jsonResponse.containsKey('teams')) {
      List<dynamic> teamsData = jsonResponse['teams'];
      List<TeamEntity> newTeams = [];
      for (var team in teamsData) {
        TeamEntity te = TeamEntity.fromJson(team);
        if (!newTeams.any((t) => t.teamNo == te.teamNo)) {
          newTeams.add(te);
        }
      }
      setTeamList(newTeams);
      await saveTeams(userId);
    }
  }

  Future<Map<String, dynamic>> inviteTeamMember(String teamName, String addMember) async {
    Map<String, dynamic> data = {
      'teamNo': getTeamNoByTeamName(teamName),
      'teamName': teamName,
      'addid': addMember,
    };
    return await WebSocketService().transmit(data, 'AddTeamMember');
  }

  Future<Map<String, dynamic>> acceptTeamMember(
      int teamNo, String teamName, String memberId, bool isExcept) async {
    Map<String, dynamic> data = {
      'teamno': teamNo,
      'teamName': teamName,
      'addid': memberId,
      'isexcept': isExcept,
    };
    return await WebSocketService().transmit(data, 'AcceptTeamRequest');
  }
}

void showInviteDialog(BuildContext context, int teamNo, String teamName, String memberId) {
  TeamManager tDB = TeamManager();
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
              await tDB.acceptTeamMember(teamNo, teamName, memberId, true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$teamName 팀의 초대를 수락하였습니다')),
              );
            },
            child: const Text('수락', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await tDB.acceptTeamMember(teamNo, teamName, memberId, false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$teamName 팀의 초대를 거절하였습니다')),
              );
            },
            child: const Text('거절', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}