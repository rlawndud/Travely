import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'model/team.dart';
import 'network/web_socket.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'team_management_page.dart';

class TeamPage extends StatefulWidget {
  final String userId;

  const TeamPage({Key? key, required this.userId}) : super(key: key);

  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _inviteIdController = TextEditingController();

  final List<Team> _teams = [];
  final Map<String, List<String>> _teamMembers = {};
  String _currentTeam = '';
  final WebSocketService _webSocketService = WebSocketService();
  TeamDB tDB = new TeamDB();

  Future<void> _loadTeams() async {
    /*final Directory directory = await getApplicationDocumentsDirectory();
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
    }*/
  }

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }
  void _showSnackBar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
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
    if (teamName.isNotEmpty) {
      var response = await _webSocketService.transmit(
          {'teamName': teamName, 'LeaderId': widget.userId}, 'AddTeam');
      if (response['result'] == 'False') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('팀이름이 이미 존재합니다.')),
        );
      } else {
        Team newTeam = Team.fromJson(response);
        setState(() {
          _teams.add(newTeam);
          _teamMembers[teamName] = [widget.userId]; // 팀 생성 시 자신을 팀에 추가
          _currentTeam = newTeam.teamName; // 생성한 팀을 현재 팀으로 설정

          _createTeamFolder(teamName);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$teamName 팀을 생성하였습니다')),
        );
      }
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
      // 상대방에게 팝업 알림 띄우기
      tDB.inviteTeamMember(
          _teams.contains(_currentTeam) as int, _currentTeam, inviteId);
    } else {
      _showSnackBar('Invalid invite ID or no team selected.');
    }
  }


  void _navigateToTeamManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TeamManagementPage(
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
                  _teams.removeWhere((team) => team.teamName == teamName);
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
              style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
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
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: _createTeam,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.all(12),
              ),
              child: const Text(
                  '팀 생성', style: TextStyle(color: Colors.white)),
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
              style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
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
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: _inviteToTeam,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.all(12),
              ),
              child: const Text('초대', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius
                          .circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('팀 관리', style: TextStyle(color: Colors
                        .white)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}