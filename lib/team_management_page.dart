import 'package:flutter/material.dart';
import 'package:travley/model/team.dart';

class TeamManagementPage extends StatefulWidget {
  final String initialCurrentTeam;
  final String userId;
  final ValueChanged<String> onTeamSwitch;
  final ValueChanged<String> onTeamDelete;

  const TeamManagementPage({
    required this.initialCurrentTeam,
    required this.userId,
    required this.onTeamSwitch,
    required this.onTeamDelete,
    super.key,
  });

  @override
  _TeamManagementPageState createState() => _TeamManagementPageState();
}

class _TeamManagementPageState extends State<TeamManagementPage> {
  late String _currentTeam;
  final TeamManager _teamManager = TeamManager();
  List<TeamEntity> teams = [];

  @override
  void initState() {
    super.initState();
    _currentTeam = widget.initialCurrentTeam;
    _teamManager.addListener(_onTeamManagerChanged);
  }

  @override
  void dispose() {
    _teamManager.removeListener(_onTeamManagerChanged);
    super.dispose();
  }

  void _onTeamManagerChanged(){
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    teams = _teamManager.getTeamList();
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
            leading: teamName == _currentTeam
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

  List<Map<String, dynamic>>? findTeamMemberByName(String teamName) {
    // 리스트를 순회하면서 팀 이름이 일치하는 팀을 찾음
    for (var team in teams) {
      if (team.teamName == teamName) {
        return team.members;
      }
    }
    return null;
  }

  List<String>? findTeamMemberNamesByName(String teamName) {
    for (var team in teams) {
      if (team.teamName == teamName) {
        return team.members.map((member) => member['name'] as String).toList();
      }
    }
    return null;
  }

  void _showTeamDetailsDialog(BuildContext context, String teamName) {
    showDialog(
      context: context,
      builder: (context) {
        final memberNames = findTeamMemberNamesByName(teamName) ?? [];
        return AlertDialog(
          title: Text('$teamName 팀 상세 정보'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('팀 멤버 목록:'),
              ...memberNames.map((memberName) => Text(memberName)).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true); // Notify that a change happened
                if (teamName != _currentTeam) {
                  setState(() {
                    _currentTeam = teamName;
                  });
                  widget.onTeamSwitch(teamName);
                  await _teamManager.saveCurTeam(widget.userId, teamName);
                }
              },
              child: Text('변경'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
                Navigator.of(context).pop();
                widget.onTeamDelete(teamName);
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
