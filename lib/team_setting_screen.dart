import 'package:flutter/material.dart';

class TeamSettingScreen extends StatefulWidget {
  final String teamName;
  final List<String> teamMembers;
  const TeamSettingScreen({super.key, required this.teamName, required this.teamMembers});

  @override
  _TeamSettingScreenState createState() => _TeamSettingScreenState();
}

class _TeamSettingScreenState extends State<TeamSettingScreen> {
  late TextEditingController _teamNameController;
  late List<String> _members;

  @override
  void initState() {
    super.initState();
    _teamNameController = TextEditingController(text: widget.teamName);
    _members = List.from(widget.teamMembers);
  }

  void _updateTeamName() {
    final newTeamName = _teamNameController.text;
    if (newTeamName.isNotEmpty) {
      setState(() {
        // Logic to update the team name in the data source would go here
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('팀 이름이 변경되었습니다')),
      );
    }
  }

  void _addMember(String newMember) {
    if (newMember.isNotEmpty) {
      setState(() {
        _members.add(newMember);
      });
    }
  }

  void _removeMember(String member) {
    setState(() {
      _members.remove(member);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.teamName} 설정'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateTeamName,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTeamNameField(),
            const SizedBox(height: 20),
            _buildMemberList(),
            const SizedBox(height: 20),
            _buildAddMemberField(),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamNameField() {
    return TextField(
      controller: _teamNameController,
      decoration: InputDecoration(
        labelText: '팀 이름',
        border: OutlineInputBorder(),
      ),
      onSubmitted: (value) => _updateTeamName(),
    );
  }

  Widget _buildMemberList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _members.length,
        itemBuilder: (context, index) {
          final member = _members[index];
          return ListTile(
            title: Text(member),
            trailing: IconButton(
              icon: Icon(Icons.remove_circle),
              onPressed: () => _removeMember(member),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddMemberField() {
    final TextEditingController _newMemberController = TextEditingController();

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _newMemberController,
            decoration: InputDecoration(
              labelText: '새 팀원 추가',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.add_circle),
          onPressed: () {
            _addMember(_newMemberController.text);
            _newMemberController.clear();
          },
        ),
      ],
    );
  }
}