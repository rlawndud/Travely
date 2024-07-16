import 'package:flutter/material.dart';

class FriendAddPage extends StatelessWidget {
  // const 생성자 사용 예시
  const FriendAddPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('친구 추가'),
      ),
      body: Center(
        child: Text('친구 추가 페이지'),
      ),
    );
  }
}
