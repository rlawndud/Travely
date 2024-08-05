import 'package:flutter/material.dart';
import 'package:test2/model/team.dart';

class TeamManagementPage extends StatelessWidget {
  final String currentTeam;
  final ValueChanged<String> onTeamSwitch;
  final ValueChanged<String> onTeamDelete;

  const TeamManagementPage({
    required this.currentTeam,
    required this.onTeamSwitch,
    required this.onTeamDelete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TeamManager teamManager = TeamManager();
    final List<TeamEntity> teams = teamManager.getTeamList();

    return Scaffold(
      appBar: AppBar(
        title: Text('팀 관리'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: ListView.builder(
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final teamName = teams[index].teamName;
          return ListTile(
            title: Text(teamName),
            leading: teamName == currentTeam
                ? Icon(Icons.check, color: Colors.pinkAccent)
                : null,
            onTap: () {
              _showTeamDetailsDialog(context, teamName, teams[index]);
            },
          );
        },
      ),
    );
  }

  void _showTeamDetailsDialog(BuildContext context, String teamName, TeamEntity team) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$teamName 팀 상세 정보'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('팀 멤버:'),
              ...team.members.map((member) => Text('${member['name']} (${member['id']})')).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onTeamSwitch(teamName);
              },
              child: Text('팀 변경'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showDeleteConfirmationDialog(context, teamName);
              },
              child: Text('팀 삭제'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String teamName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('팀 삭제'),
          content: Text('$teamName 팀을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onTeamDelete(teamName);
              },
              child: Text('삭제'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }
}