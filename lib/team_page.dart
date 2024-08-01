import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'team_management_page.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({Key? key}) : super(key: key);

  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _inviteIdController = TextEditingController();

  List<String> _teams = [];
  final Map<String, List<String>> _teamMembers = {};
  String _currentTeam = '';

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/teams.json');
    if (await file.exists()) {
      final String contents = await file.readAsString();
      final data = json.decode(contents) as Map<String, dynamic>;
      setState(() {
        _teams = List<String>.from(data['teams'] as List<dynamic>);
        final membersMap = data['members'] as Map<String, dynamic>;
        _teamMembers.addAll(membersMap.map((k, v) => MapEntry(k, List<String>.from(v))));
        _currentTeam = data['currentTeam'] ?? '';
      });
    }
  }

  Future<void> _saveTeams() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/teams.json');
    final data = {
      'teams': _teams,
      'members': _teamMembers,
      'currentTeam': _currentTeam,
    };
    await file.writeAsString(json.encode(data));
  }

  Future<void> _createTeam() async {
    String teamName = _teamNameController.text;
    if (teamName.isNotEmpty && !_teams.contains(teamName)) {
      setState(() {
        _teams.add(teamName);
        _teamMembers[teamName] = ['MyID'];
        _currentTeam = teamName;
      });

      await _createTeamFolder(teamName);
      await _saveTeams();
      _showSnackBar('$teamName 팀을 생성하였습니다');
    } else {
      _showSnackBar('팀이름이 이미 존재하거나 팀이름이 비어있습니다');
    }
  }

  Future<void> _createTeamFolder(String folderName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = '${directory.path}/$folderName';
    final Directory folder = Directory(path);

    if (!await folder.exists()) {
      await folder.create(recursive: true);
      print('Folder created at: $path');
    } else {
      print('Folder already exists at: $path');
    }
  }

  void _inviteToTeam() {
    String inviteId = _inviteIdController.text;
    if (inviteId.isNotEmpty && _currentTeam.isNotEmpty) {
      _showInvitationDialog(inviteId, _currentTeam);
    } else {
      _showSnackBar('Invalid invite ID or no team selected.');
    }
  }

  void _showInvitationDialog(String inviteId, String teamName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('팀 초대'),
          content: Text('$teamName 팀이 $inviteId 님을 초대하였습니다. 수락하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  if (_teamMembers.containsKey(teamName)) {
                    _teamMembers[teamName]?.add(inviteId);
                  }
                });
                _sendInvitationResponse(inviteId, teamName, '수락');
                _showSnackBar('$inviteId 님이 초대를 수락하였습니다');
              },
              child: Text('수락'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _sendInvitationResponse(inviteId, teamName, '거절');
                _showSnackBar('$inviteId 님이 초대를 거절하였습니다');
              },
              child: Text('거절'),
            ),
          ],
        );
      },
    );
  }

  void _sendInvitationResponse(String inviteId, String teamName, String response) {
    print('$inviteId에게 $teamName 팀 초대 응답: $response');
  }

  void _navigateToTeamManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamManagementPage(
          teams: _teams,
          teamMembers: _teamMembers,
          currentTeam: _currentTeam,
          onTeamSwitch: (teamName) {
            setState(() {
              _currentTeam = teamName;
            });
          },
          onTeamDelete: (teamName) {
            setState(() {
              _teams.remove(teamName);
              _teamMembers.remove(teamName);
              if (_currentTeam == teamName) {
                _currentTeam = '';
              }
            });
            _saveTeams();
            _showSnackBar('$teamName 팀이 삭제되었습니다');
          },
        ),
      ),
    ).then((value) {
      if (value == true) {
        _loadTeams(); // 팀 관리 후 팀 목록 새로고침
      }
    });
  }

  void _showSnackBar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: ListView(
                children: [
                  _buildCreateTeamSection(),
                  const SizedBox(height: 10),
                  _buildInviteSection(),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: _navigateToTeamManagement,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('팀 관리', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateTeamSection() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '팀 생성',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _teamNameController,
              decoration: InputDecoration(
                labelText: '팀 이름',
                labelStyle: TextStyle(color: Colors.black, fontSize: 14),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pinkAccent),
                  borderRadius: BorderRadius.circular(8),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: _createTeam,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.all(12),
              ),
              child: const Text('팀 생성', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteSection() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '팀 초대',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _inviteIdController,
              decoration: InputDecoration(
                labelText: '초대 ID',
                labelStyle: TextStyle(color: Colors.black, fontSize: 14),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pinkAccent),
                  borderRadius: BorderRadius.circular(8),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: _inviteToTeam,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.all(12),
              ),
              child: const Text('초대', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
