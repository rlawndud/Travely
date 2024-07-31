import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../network/web_socket.dart';

class Team {
  int? teamNo;
  String teamName;
  String leaderId;

  Team(this.teamNo, this.teamName, this.leaderId);

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      json['teamNo'] as int?,
      json['teamName'] as String,
      json['leaderId'] as String,
    );
  }

  // Member 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'teamNo': teamNo,
      'teamName': teamName,
      'leaderId': leaderId,
    };
  }
}

class TeamDB {
  final WebSocketService _webSocketService = WebSocketService();
  static List<Team> teams = [];

  // Team newt = new Team(null,'aa','rlawndud');
  // Team newt2 = new Team(null,'bb','rlawndud');
  //
  // teams.add(newt);
  //
  void loadTeam(String userId) async {
    Map<String, dynamic> data = {'userId': userId};
    var jsonResponse = await _webSocketService.transmit(data, 'Loadteam');

    if (jsonResponse.containsKey('teams')) {
      List<dynamic> teamsData = jsonResponse['teams'];
      teams = teamsData.map((teamData) => Team.fromJson(teamData)).toList();
    }
  }

  void createTeam(String teamName, String leaderId) async {
    List<String> teamMember = [];
    teamMember.add(leaderId);
    Team team = new Team(null, teamName, leaderId);
    _webSocketService.transmit(team.toJson(), 'AddTeam');
  }

  Future<Map<String, dynamic>> inviteTeamMember(
      int teamNo, String addMember) async {
    Map<String, dynamic> data = {
      'teamNo': teamNo,
      'member': addMember,
    };
    return await _webSocketService.transmit(data, 'InviteTeam');
  }

  Future<Map<String, dynamic>> acceptTeamMember(
      int teamNo, String addMember) async {
    Map<String, dynamic> data = {
      'teamNo': teamNo,
      'member': addMember,
    };
    return await _webSocketService.transmit(data, 'InviteTeam');
  }
}

void showInviteDialog(BuildContext context, int teamNo, String teamName, String memberId) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('팀 초대'),
          content: Text('$memberId 님을 $teamName 팀에 초대하였습니다. 수락하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 초대 수락 시 팀 멤버 목록에 추가
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$memberId 님이 초대를 수락하였습니다')),
                );
              },
              child: Text('수락'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$memberId 님이 초대를 거절하였습니다')),
                );
              },
              child: Text('거절'),
            ),
          ],
        );
      });
}
