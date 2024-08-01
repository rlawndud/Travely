import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:test2/value/color.dart';

import '../network/web_socket.dart';

class Team {
  int teamNo;
  String teamName;
  String leaderId; //이게머야

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

  Future<Map<String, dynamic>> inviteTeamMember(
      int teamNo, String teamName, String addMember) async {
    Map<String, dynamic> data = {
      'teamno': teamNo,
      'teamName': teamName,
      'addid': addMember,
    };
    return await _webSocketService.transmit(data, 'InviteTeam');
  }

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
  TeamDB tDB = new TeamDB();
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
