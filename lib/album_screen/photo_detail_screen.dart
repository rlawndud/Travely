import 'package:flutter/material.dart';
import 'package:test2/model/memberImg.dart';
import 'package:test2/model/picture.dart';

class ImageDetailScreen extends StatelessWidget {
  final PictureEntity picture;
  final String teamName;
  final String category;
  final String subCategory;

  const ImageDetailScreen({
    Key? key,
    required this.picture,
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
              child: Image.memory(
                BytesToImage(picture.img_data),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
                _getImageAnalysis(),
              style: TextStyle(fontSize: 16),
            )
          ),
        ],
      ),
    );
  }

  String _getImageAnalysis() {

    return picture.printPredict();
  }
}