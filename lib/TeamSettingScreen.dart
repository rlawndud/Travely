import 'package:flutter/material.dart';

class TeamSettingScreen extends StatelessWidget {
  const TeamSettingScreen({Key? key}) : super(key: key);

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
              decoration: InputDecoration(labelText: '팀 이름'),
              onSubmitted: (value) {
                // 서버로 팀 생성 요청
              },
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('팀 생성'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('사용자 초대'),
            ),
          ],
        ),
      ),
    );
  }
}
