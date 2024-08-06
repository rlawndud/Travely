import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:test2/model/picture.dart';
import 'package:test2/model/team.dart';

class PhotoFolderScreen extends StatefulWidget {
  const PhotoFolderScreen({Key? key}) : super(key: key);

  @override
  _PhotoFolderScreenState createState() => _PhotoFolderScreenState();
}

class _PhotoFolderScreenState extends State<PhotoFolderScreen> {
  final TeamManager _teamManager = TeamManager();
  final PicManager _picManager = PicManager();
  late StreamSubscription<PictureEntity> _picSubscription;

  @override
  void initState() {
    super.initState();
    _loadTeamFolders();
    _subscribeToNewImages();
  }

  @override
  void dispose() {
    _picSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadTeamFolders() async {
    List<TeamEntity> teams = _teamManager.getTeamList();
    for (var team in teams) {
      await _createTeamFolderStructure(team.teamName);
    }
    setState(() {});
  }

  Future<void> _createTeamFolderStructure(String teamName) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String teamPath = '${appDir.path}/$teamName';

    await Directory(teamPath).create(recursive: true);
    await Directory('$teamPath/전체사진').create(recursive: true);
    await Directory('$teamPath/지역').create(recursive: true);
    await Directory('$teamPath/배경').create(recursive: true);
    await Directory('$teamPath/계절').create(recursive: true);

    List<String> cities = ['서울', '대전', '부산', '인천', '대구', '울산', '광주', '제주도', '기타 지역'];
    for (var city in cities) {
      await Directory('$teamPath/지역/$city').create(recursive: true);
    }

    List<String> backgrounds = ['산', '바다', '기타'];
    for (var background in backgrounds) {
      await Directory('$teamPath/배경/$background').create(recursive: true);
    }

    List<String> seasons = ['봄', '여름', '가을', '겨울'];
    for (var season in seasons) {
      await Directory('$teamPath/계절/$season').create(recursive: true);
    }
  }

  void _subscribeToNewImages() {
    _picSubscription = _picManager.imageStream.listen((newImage) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('새로운 사진이 추가되었습니다: ${newImage.img_num}'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<TeamEntity> teams = _teamManager.getTeamList();

    return Scaffold(
      appBar: AppBar(
        title: Text('팀 앨범'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: teams.length,
        itemBuilder: (context, index) {
          return _buildTeamItem(teams[index].teamName);
        },
      ),
    );
  }

  Widget _buildTeamItem(String teamName) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeamAlbumScreen(teamName: teamName),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(
            teamName,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class TeamAlbumScreen extends StatelessWidget {
  final String teamName;

  const TeamAlbumScreen({Key? key, required this.teamName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$teamName 팀 앨범'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: ListView(
        children: [
          _buildAlbumTile(context, '전체사진'),
          _buildAlbumTile(context, '지역'),
          _buildAlbumTile(context, '배경'),
          _buildAlbumTile(context, '계절'),
        ],
      ),
    );
  }

  Widget _buildAlbumTile(BuildContext context, String category) {
    return ListTile(
      title: Text(category),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubCategoryScreen(
              teamName: teamName,
              category: category,
            ),
          ),
        );
      },
    );
  }
}

class SubCategoryScreen extends StatelessWidget {
  final String teamName;
  final String category;

  const SubCategoryScreen({Key? key, required this.teamName, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category 앨범'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: ListView(
        children: _getSubCategories().map((subCategory) {
          return ListTile(
            title: Text(subCategory),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoGridScreen(
                    teamName: teamName,
                    category: category,
                    subCategory: subCategory,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  List<String> _getSubCategories() {
    switch (category) {
      case '전체사진':
        return [''];
      case '계절':
        return ['봄', '여름', '가을', '겨울'];
      case '지역':
        return ['서울', '대전', '부산', '인천', '대구', '울산', '광주', '제주도', '기타 지역'];
      case '배경':
        return ['산', '바다', '기타'];
      default:
        return [];
    }
  }
}

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