import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('로그아웃'),
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            leading: Icon(Icons.close),
            title: Text('회원 탈퇴'),
            trailing: Icon(Icons.navigate_next),
          ),
        ],
      ),
    );
  }
}
