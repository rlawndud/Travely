import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  // const 생성자 사용 예시
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
      ),
      body: Center(
        child: Text('설정 페이지'),
      ),
    );
  }
}
