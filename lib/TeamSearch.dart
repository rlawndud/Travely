import 'package:flutter/material.dart';

class TeamSearchPage extends StatelessWidget {
  // const 생성자 사용 예시
  const TeamSearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('팀 검색'),
      ),
      body: Center(
        child: Text('팀 검색 페이지'),
      ),
    );
  }
}
