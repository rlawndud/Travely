import 'package:flutter/material.dart';

class TeamManagementPage extends StatelessWidget {
  final List<String> teams;
  final Map<String, List<String>> teamMembers;
  final String currentTeam;
  final ValueChanged<String> onTeamSwitch;
  final ValueChanged<String> onTeamDelete;

  const TeamManagementPage({
    required this.teams,
    required this.teamMembers,
    required this.currentTeam,
    required this.onTeamSwitch,
    required this.onTeamDelete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('팀 관리'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: ListView.builder(
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final teamName = teams[index];
          return ListTile(
            title: Text(teamName),
            leading: teamName == currentTeam
                ? Icon(Icons.check, color: Colors.pinkAccent)
                : null,
            onTap: () {
              _showTeamDetailsDialog(context, teamName);
            },
          );
        },
      ),
    );
  }

  void _showTeamDetailsDialog(BuildContext context, String teamName) {
    showDialog(
      context: context,
      builder: (context) {
        final members = teamMembers[teamName] ?? [];
        return AlertDialog(
          title: Text('$teamName 팀 상세 정보'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('팀 멤버 목록:'),
              ...members.map((member) => Text(member)).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Notify that a change happened
                if (teamName != currentTeam) {
                  onTeamSwitch(teamName);
                }
              },
              child: Text('변경'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog first
                _showDeleteConfirmationDialog(context, teamName);
              },
              child: Text('삭제'),
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
                Navigator.of(context).pop(); // Close dialog first
                onTeamDelete(teamName);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$teamName 팀이 삭제되었습니다')),
                );
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
