import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:travley/appbar/mypage/EditInfo.dart';
import 'package:travley/model/member.dart';

class MyPage extends StatelessWidget {
  final Member user;
  const MyPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('𝑴𝒚 𝑷𝒂𝒈𝒆'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.add_circle),
            title: const Text('정보 수정'),
            trailing: const Icon(Icons.navigate_next),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditInfoPage(user: user)),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.security),
            title: Text('어플 권한 설정'),
            trailing: Icon(Icons.navigate_next),
            onTap: AppSettings.openAppSettings,
          ),
        ],
      ),
    );
  }
}
