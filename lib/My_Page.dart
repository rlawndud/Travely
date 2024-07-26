import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Page'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.person_add_alt_sharp),
            title: Text('친구 추가'),
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            leading: Icon(Icons.person_add_disabled),
            title: Text('친구 편집'),
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            leading: Icon(Icons.add_circle),
            title: Text('정보 수정'),
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            leading: Icon(Icons.security),
            title: Text('어플 권한 설정'),
            trailing: Icon(Icons.navigate_next),
          ),
        ],
      ),
    );
  }
}
