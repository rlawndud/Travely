import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'model/team.dart';
import 'network/web_socket.dart';

class TeamPage extends StatefulWidget {
  // const TeamPage({Key? key,}) : super(key: key);
  final String userId;

  // final List<Team> teams;
  const TeamPage({Key? key, required this.userId}) : super(key: key);

  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _inviteIdController = TextEditingController();
  final TextEditingController _searchTeamNameController =
      TextEditingController();

  final List<Team> _teams = [];
  final Map<String, List<String>> _teamMembers = {};
  String _currentTeam = '';
  final WebSocketService _webSocketService = WebSocketService();
  TeamDB tDB = new TeamDB();

  void _createTeam() async {
    String teamName = _teamNameController.text;
    if (teamName.isNotEmpty) {
      var response = await _webSocketService.transmit(
          {'teamName': teamName, 'LeaderId': widget.userId}, 'AddTeam');
      if(response['result']=='False'){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('팀이름이 이미 존재합니다.')),
        );
      }else{
        Team newTeam = Team.fromJson(response);
        setState(() {
          _teams.add(newTeam);
          _teamMembers[teamName] = [widget.userId]; // 팀 생성 시 자신을 팀에 추가
          _currentTeam = newTeam.teamName; // 생성한 팀을 현재 팀으로 설정
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$teamName 팀을 생성하였습니다')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('팀이름이 비어있습니다')),
      );
    }
  }

  void _inviteToTeam() {
    String inviteId = _inviteIdController.text;
    if (inviteId.isNotEmpty && _currentTeam.isNotEmpty) {
      // 상대방에게 팝업 알림 띄우기
      tDB.inviteTeamMember(_teams.contains(_currentTeam) as int, _currentTeam, inviteId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('초대 ID가 잘못되었거나 팀이 선택되지 않았습니다.')),
      );
    }
  }


  void _navigateToTeamManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamManagementPage(
          teams: _teams,
          teamMembers: _teamMembers,
          currentTeam: _currentTeam,
          onTeamSwitch: _switchTeam,
        ),
      ),
    );
  }

  void _switchTeam(String teamName) {
    setState(() {
      _currentTeam = teamName;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('현재 팀이 $_currentTeam 으로 변경되었습니다')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // Remove AppBar
      body: Container(
        color: Colors.white, // Light background color
        padding: const EdgeInsets.all(8.0), // Reduced padding
        child: Column(
          children: [
            Expanded(
              flex: 4, // Space for the input sections
              child: ListView(
                children: [
                  _buildCreateTeamSection(),
                  const SizedBox(height: 10), // Reduced spacing
                  _buildInviteSection(),
                  const SizedBox(height: 10), // Reduced spacing
                ],
              ),
            ),
            Expanded(
              flex: 1, // Space for the button
              child: Center(
                child: SizedBox(
                  width: 200, // Adjusted width
                  child: ElevatedButton(
                    onPressed: _navigateToTeamManagement,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      // Reduced border radius
                      padding: const EdgeInsets.symmetric(
                          vertical: 12), // Adjusted vertical padding
                    ),
                    child: const Text('팀 관리',
                        style: TextStyle(color: Colors.white)),
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
      // Reduced elevation
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      // Reduced border radius
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '팀 생성',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black), // Reduced font size
            ),
            const SizedBox(height: 5), // Reduced spacing
            TextField(
              controller: _teamNameController,
              decoration: InputDecoration(
                labelText: '팀 이름',
                labelStyle: TextStyle(color: Colors.black, fontSize: 14),
                // Reduced font size
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pinkAccent),
                  borderRadius:
                      BorderRadius.circular(8), // Reduced border radius
                ),
                border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(8)), // Reduced border radius
              ),
            ),
            const SizedBox(height: 5), // Reduced spacing
            ElevatedButton(
              onPressed: _createTeam,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                // Reduced border radius
                padding: const EdgeInsets.all(12), // Reduced padding
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
      // Reduced elevation
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      // Reduced border radius
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '팀 초대',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black), // Reduced font size
            ),
            const SizedBox(height: 5), // Reduced spacing
            TextField(
              controller: _inviteIdController,
              decoration: InputDecoration(
                labelText: '상대방 ID',
                labelStyle: TextStyle(color: Colors.black, fontSize: 14),
                // Reduced font size
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pinkAccent),
                  borderRadius:
                      BorderRadius.circular(8), // Reduced border radius
                ),
                border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(8)), // Reduced border radius
              ),
            ),
            const SizedBox(height: 5), // Reduced spacing
            ElevatedButton(
              onPressed: _inviteToTeam,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                // Reduced border radius
                padding: const EdgeInsets.all(12), // Reduced padding
              ),
              child: const Text('초대', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class TeamManagementPage extends StatefulWidget {
  final List<Team> teams;
  final Map<String, List<String>> teamMembers;
  final String currentTeam;
  final ValueChanged<String> onTeamSwitch;

  const TeamManagementPage({
    required this.teams,
    required this.teamMembers,
    required this.currentTeam,
    required this.onTeamSwitch,
    Key? key,
  }) : super(key: key);

  @override
  _TeamManagementPageState createState() => _TeamManagementPageState();
}

class _TeamManagementPageState extends State<TeamManagementPage> {
  String? _selectedTeam;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedTeam != null) {
          setState(() {
            _selectedTeam = null; // 팀 세부 사항 화면에서 뒤로가기 시 팀 목록으로 돌아감
          });
          return false; // 화면이 뒤로 가지 않도록 막음
        }
        return true; // 팀 목록 화면에서 뒤로가기 시 기본 동작 수행
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('팀 관리'),
          backgroundColor: Colors.pinkAccent,
        ),
        body: _selectedTeam == null ? _buildTeamList() : _buildTeamDetails(),
      ),
    );
  }

  Widget _buildTeamList() {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        ...widget.teams.map((team) {
          return ListTile(
            title: Text(team.teamName),
            onTap: () => _selectTeam(team.teamName),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTeamDetails() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              Text(
                '팀: $_selectedTeam',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...widget.teamMembers[_selectedTeam!]!.map((member) {
                return ListTile(
                  title: Text(member),
                );
              }).toList(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: _switchTeam,
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedTeam == widget.currentTeam
                  ? Colors.grey
                  : Colors.pinkAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(
                  vertical: 12), // Adjusted vertical padding
            ),
            child: Text(
              _selectedTeam == widget.currentTeam ? '현재 팀' : '팀 설정',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _selectTeam(String teamName) {
    setState(() {
      _selectedTeam = teamName;
    });
  }

  void _switchTeam() {
    if (_selectedTeam != null) {
      widget.onTeamSwitch(_selectedTeam!);
      Navigator.popUntil(context, (route) => route.isFirst); // 팀 목록 화면으로 돌아감
    }
  }
}
