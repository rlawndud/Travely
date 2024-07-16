// TeamSettingScreen.dart

import 'package:flutter/material.dart';

class TeamSettingScreen extends StatefulWidget {
  const TeamSettingScreen({Key? key}) : super(key: key);

  @override
  _TeamSettingScreenState createState() => _TeamSettingScreenState();
}

class _TeamSettingScreenState extends State<TeamSettingScreen> {
  TextEditingController _teamNameController = TextEditingController();
  String? _teamName;

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }

  void _setTeamName() {
    setState(() {
      _teamName = _teamNameController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('팀 설정'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _teamNameController,
              decoration: InputDecoration(
                labelText: '팀 이름',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _setTeamName();
                Navigator.pop(context, _teamName); // 화면 닫기 및 결과 전달
              },
              child: Text('팀 설정 완료'),
            ),
          ],
        ),
      ),
    );
  }
}