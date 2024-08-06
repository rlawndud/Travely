import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class PhotoViewPage extends StatefulWidget {
  final String teamName;
  final String category;

  const PhotoViewPage({super.key, required this.teamName, required this.category});

  @override
  _PhotoViewPageState createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  List<File> _photos = [];
  List<String> _subCategories = [];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String path = '${appDir.path}/${widget.teamName}/${widget.category}';
    final Directory dir = Directory(path);

    if (widget.category == '전체사진') {
      final List<FileSystemEntity> entities = await dir.list().toList();
      setState(() {
        _photos = entities.whereType<File>().toList();
      });
    } else {
      final List<FileSystemEntity> entities = await dir.list().toList();
      setState(() {
        _subCategories = entities
            .whereType<Directory>()
            .map((dir) => dir.path.split('/').last)
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.teamName} - ${widget.category}'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: widget.category == '전체사진'
          ? GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          return _buildPhotoItem(_photos[index]);
        },
      )
          : ListView.builder(
        itemCount: _subCategories.length,
        itemBuilder: (context, index) {
          return _buildSubCategoryItem(_subCategories[index]);
        },
      ),
    );
  }

  Widget _buildPhotoItem(File photo) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoDetailPage(photo: photo),
          ),
        );
      },
      child: Image.file(
        photo,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildSubCategoryItem(String subCategory) {
    return ListTile(
      title: Text(subCategory),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoViewPage(
              teamName: widget.teamName,
              category: '${widget.category}/$subCategory',
            ),
          ),
        );
      },
    );
  }
}

class PhotoDetailPage extends StatelessWidget {
  final File photo;

  const PhotoDetailPage({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('사진 상세'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.file(
              photo,
              fit: BoxFit.contain,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              '분석된 내용: [서버에서 받은 분석 내용]',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
