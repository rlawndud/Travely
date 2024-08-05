import 'package:flutter/material.dart';
import 'package:test2/model/team.dart';
import 'package:test2/network/web_socket.dart';
import 'package:test2/team_management_page.dart';
import 'package:test2/value/color.dart';

class TeamPage extends StatefulWidget {
  final String userId;

  const TeamPage({Key? key, required this.userId}) : super(key: key);

  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _inviteIdController = TextEditingController();

  final TeamManager _teamManager = TeamManager();
  String _currentTeam = '';
  final WebSocketService _webSocketService = WebSocketService();

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    await _teamManager.loadTeam(widget.userId);
    setState(() {});
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _createTeam() async {
    String teamName = _teamNameController.text;
    if (teamName.isNotEmpty) {
      var response = await _webSocketService.transmit({'teamName': teamName, 'LeaderId': widget.userId}, 'AddTeam');
      if (response['result'] == 'False') {
        _showSnackBar('팀이름이 이미 존재합니다.');
      } else {
        await _teamManager.loadTeam(widget.userId);
        setState(() {
          _currentTeam = teamName;
        });
        _showSnackBar('$teamName 팀을 생성하였습니다');
      }
    } else {
      _showSnackBar('팀이름이 비어있습니다');
    }
  }

  void _inviteToTeam() {
    String inviteId = _inviteIdController.text;
    if (inviteId.isNotEmpty && _currentTeam.isNotEmpty) {
      _teamManager.inviteTeamMember(_currentTeam, inviteId);
    } else {
      _showSnackBar('Invalid invite ID or no team selected.');
    }
  }

  void _navigateToTeamManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamManagementPage(
          currentTeam: _currentTeam,
          onTeamSwitch: (teamName) {
            setState(() {
              _currentTeam = teamName;
            });
          },
          onTeamDelete: (teamName) {
            _showSnackBar('$teamName 팀이 삭제되었습니다');
          },
        ),
      ),
    ).then((value) {
      if (value == true) {
        _loadTeams();
      }
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