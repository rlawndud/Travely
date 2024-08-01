import 'package:flutter/material.dart';

class PhotoGridScreen extends StatelessWidget {
  final String teamName;
  final String category;
  final String subCategory;

  const PhotoGridScreen({
    Key? key,
    required this.teamName,
    required this.category,
    required this.subCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category - $subCategory 앨범'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemBuilder: (context, index) {
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: Text('사진 $index'),
            ),
          );
        },
        itemCount: 20, // 더미 데이터 - 실제 사진 수로 교체
      ),
    );
  }
}
