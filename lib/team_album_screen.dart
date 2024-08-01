import 'package:flutter/material.dart';
import 'sub_category_screen.dart'; // 서브카테고리 화면으로의 경로를 맞춰야 합니다

class TeamAlbumScreen extends StatelessWidget {
  final String teamName;

  const TeamAlbumScreen({Key? key, required this.teamName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$teamName 팀 앨범'),
      ),
      body: ListView(
        children: [
          _buildAlbumTile(context, '계절'),
          _buildAlbumTile(context, '지역'),
          _buildAlbumTile(context, '배경'),
        ],
      ),
    );
  }

  Widget _buildAlbumTile(BuildContext context, String category) {
    return ListTile(
      title: Text(category),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/subCategory',
          arguments: {
            'teamName': teamName,
            'category': category,
          },
        );
      },
    );
  }
}
