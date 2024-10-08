import 'package:flutter/material.dart';
import 'package:travley/album_screen/photo_grid_screen.dart';

class SubCategoryScreen extends StatelessWidget {
  final String teamName;
  final String category;
  final List<Map<String, dynamic>> teamMembers;

  const SubCategoryScreen({super.key, required this.teamName, required this.category, required this.teamMembers});

  @override
  Widget build(BuildContext context) {
    if (category == '전체사진') {
      // 전체사진 카테고리일 경우 바로 PhotoGridScreen으로 이동
      return PhotoGridScreen(
        teamName: teamName,
        category: category,
        subCategory: '',
        teamMembers: [],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$category 앨범'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: ListView(
        children: _getSubCategories().map((subCategory) {
          return ListTile(
            title: Text(subCategory),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoGridScreen(
                    teamName: teamName,
                    category: category,
                    subCategory: subCategory,
                    teamMembers: teamMembers,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  List<String> _getSubCategories() {
    switch (category) {
      case '계절':
        return ['봄', '여름', '가을', '겨울'];
      case '지역':
        return ['서울', '대전', '부산', '인천', '대구', '울산', '광주', '제주도', '기타 지역'];
      case '멤버':
      case '촬영자':
        return teamMembers.map((member) => member['name'] as String).toList();
      default:
        return [];
    }
  }
}