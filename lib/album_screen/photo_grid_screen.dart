import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test2/album_screen/photo_detai_screen.dart';

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
        backgroundColor: Colors.pinkAccent,
      ),
      body: FutureBuilder<List<File>>(
        future: _getImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageDetailScreen(
                            imageFile: snapshot.data![index],
                            teamName: teamName,
                            category: category,
                            subCategory: subCategory,
                          ),
                        ),
                      );
                    },
                    child: Image.file(
                      snapshot.data![index],
                      fit: BoxFit.cover,
                    ),
                  );
                },
              );
            } else {
              return Center(child: Text('No images found'));
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<List<File>> _getImages() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String path = category == '전체사진'
        ? '${appDir.path}/$teamName/$category'
        : '${appDir.path}/$teamName/$category/$subCategory';
    final Directory dir = Directory(path);
    if (await dir.exists()) {
      final List<FileSystemEntity> entities = await dir.list().toList();
      return entities.whereType<File>().toList();
    }
    return [];
  }
}