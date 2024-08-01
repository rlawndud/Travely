import 'package:flutter/material.dart';

class AlbumDetailPage extends StatelessWidget {
  final String folderName;

  const AlbumDetailPage({Key? key, required this.folderName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(folderName),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Center(
        child: Text('Album Details for $folderName'),
      ),
    );
  }
}
