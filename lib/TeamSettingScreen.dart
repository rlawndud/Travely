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
            ElevatedButton(
              onPressed: () {},
              child: Text('팀 이름'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('팀 초대'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('팀 찾기'),
            ),
          ],
        ),
      ),
    );
  }
}
