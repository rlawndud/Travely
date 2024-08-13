import 'package:flutter/material.dart';
import 'model/team.dart';
import 'network/web_socket.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'team_management_page.dart';

class TeamPage extends StatefulWidget {
  final String userId;

  const TeamPage({super.key, required this.userId});

  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _inviteIdController = TextEditingController();

  List<TeamEntity> _teams = [];
  final Map<String, List<String>> _teamMembers = {};
  String _currentTeam = '';
  final WebSocketService _webSocketService = WebSocketService();
  late TeamManager _teamManager;

  Future<void> _loadTeams() async {
    setState(() {
      _teams = _teamManager.getTeamList();
      _currentTeam = _teamManager.currentTeam;
    });
  }

  @override
  void initState() {
    super.initState();
    _teamManager = TeamManager();
    _loadTeams();
  }

  void _showSnackBar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  Future<void> _createTeam() async {
    String teamName = _teamNameController.text;
    if (teamName.isNotEmpty) {
      var response = await _webSocketService.transmit({'teamName': teamName, 'LeaderId': widget.userId}, 'AddTeam');
      if (response['result'] == 'False') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('팀이름이 이미 존재합니다.')),
        );
      } else {
        await _teamManager.loadTeam();
        setState(() {
          _currentTeam = teamName;
          _teamManager.currentTeam = teamName;
          _teams = _teamManager.getTeamList();
        });
        _createTeamFolder(teamName);
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
      _teamManager.inviteTeamMember(_currentTeam, inviteId);
    } else {
      _showSnackBar('초대 ID가 비어있거나 선택된 팀이 없습니다.');
    }
  }

  void _navigateToTeamManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamManagementPage(
          teams: _teamManager.getTeamList(),
          initialCurrentTeam: _teamManager.currentTeam,
          userId: widget.userId,
          onTeamSwitch: (teamName) {
            setState(() {
              _currentTeam = teamName;
              _teamManager.currentTeam = teamName;
            });
          },
          onTeamDelete: (teamName) {
            // ... 기존 코드 ...
          },
        ),
      ),
    ).then((value) {
      if (value == true) {
        _loadTeams();
      }
    });
  }

  void _startTravel() async {
    if (_currentTeam.isNotEmpty) {
      int? currentTeamNo = _teamManager.getTeamNoByTeamName(_currentTeam);
      if (currentTeamNo != null) {
        Map<String, dynamic> team = {
          'teamNo': currentTeamNo,
        };
        var response = await _webSocketService.transmit(team, 'TravelStart');
        print(team);
        if(response['result']=='True'){
          _showSnackBar('여행 준비가 완료되었습니다');
        }else if(response.containsKey('error')){
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('여행 준비 중 문제가 생겼습니다'),
                backgroundColor: Colors.red,
              ),
            );
          });
        }
      } else {
        _showSnackBar('팀 번호를 찾을 수 없습니다');
      }
    } else {
      _showSnackBar('먼저 팀을 선택해주세요');
    }
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

  Widget _buildManagementSection() {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
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
            const SizedBox(height: 10),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: _startTravel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('여행 시작', style: TextStyle(color: Colors.white)),
              ),
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
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            _buildCreateTeamSection(),
                            const SizedBox(height: 10),
                            _buildInviteSection(),
                          ],
                        ),
                      ),
                      Expanded(child: Container()),
                      _buildManagementSection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
