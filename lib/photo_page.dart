import 'package:flutter/material.dart';

class PhotoPage extends StatelessWidget {
  final String folderName;

  PhotoPage({required this.folderName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(folderName),
      ),
      body: Center(
        child: Text('Photos in $folderName'),
      ),
    );
  }
}
