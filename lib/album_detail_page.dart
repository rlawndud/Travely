// lib/album_detail_page.dart
import 'package:flutter/material.dart';

class AlbumDetailPage extends StatelessWidget {
  final String albumTitle;
  final List<String> albumImages;

  const AlbumDetailPage({
    Key? key,
    required this.albumTitle,
    required this.albumImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(albumTitle),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Number of columns in the album
          crossAxisSpacing: 4.0, // Horizontal space between images
          mainAxisSpacing: 4.0, // Vertical space between images
        ),
        padding: const EdgeInsets.all(10.0),
        itemCount: albumImages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // TODO: Implement action on image tap
            },
            child: Image.asset(
              albumImages[index],
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
