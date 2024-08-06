import 'dart:io';

import 'package:flutter/material.dart';

class ImageDetailScreen extends StatelessWidget {
  final File imageFile;
  final String teamName;
  final String category;
  final String subCategory;

  const ImageDetailScreen({
    Key? key,
    required this.imageFile,
    required this.teamName,
    required this.category,
    required this.subCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Detail'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.file(
                imageFile,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<String>(
              future: _getImageAnalysis(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Text(
                    snapshot.data ?? 'No analysis available',
                    style: TextStyle(fontSize: 16),
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _getImageAnalysis() async {
    // 이 부분에서 실제로 이미지 분석 데이터를 가져오는 로직을 구현해야 합니다.
    // 현재는 더미 데이터를 반환합니다.
    await Future.delayed(Duration(seconds: 1)); // 분석 시간을 시뮬레이션
    return '사진 속 인물: 홍길동\n사진 배경: 해변';
  }
}