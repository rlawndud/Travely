import 'package:flutter/material.dart';

class SubCategoryScreen extends StatelessWidget {
  final String teamName;
  final String category;

  const SubCategoryScreen({super.key, required this.teamName, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category 앨범'),
      ),
      body: ListView(
        children: _getSubCategories().map((subCategory) {
          return ListTile(
            title: Text(subCategory),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/photoGrid',
                arguments: {
                  'teamName': teamName,
                  'category': category,
                  'subCategory': subCategory,
                },
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
        return ['서울', '대전', '인천', '부산', '제주도'];
      case '배경':
        return ['산', '바다'];
      default:
        return [];
    }
  }
}
