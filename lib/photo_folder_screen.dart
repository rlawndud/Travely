import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'album_detail_page.dart';

class PhotoFolderScreen extends StatefulWidget {
  const PhotoFolderScreen({Key? key}) : super(key: key);

  @override
  _PhotoFolderScreenState createState() => _PhotoFolderScreenState();
}

class _PhotoFolderScreenState extends State<PhotoFolderScreen> {
  List<String> _folderPaths = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final List<String> folders = directory
        .listSync()
        .where((entity) => entity is Directory)
        .map((entity) => entity.path.split('/').last)
        .toList();

    setState(() {
      _folderPaths = folders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
          ),
          itemCount: _folderPaths.length,
          itemBuilder: (context, index) {
            return _buildGridItem(_folderPaths[index]);
          },
        ),
      ),
    );
  }

  Widget _buildGridItem(String folderName) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlbumDetailPage(folderName: folderName),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(
            folderName,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
