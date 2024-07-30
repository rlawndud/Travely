import 'package:flutter/material.dart';
import 'package:test2/EditInfo.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

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
                MaterialPageRoute(builder: (context) => EditInfoPage()),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.security),
            title: Text('어플 권한 설정'),
            trailing: Icon(Icons.navigate_next),
          ),
        ],
      ),
    );
  }
}

