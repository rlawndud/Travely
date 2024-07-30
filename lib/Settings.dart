import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
