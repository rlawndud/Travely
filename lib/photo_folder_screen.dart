import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'album_detail_page.dart';
import 'package:test2/model/team.dart';

class PhotoFolderScreen extends StatefulWidget {
  const PhotoFolderScreen({super.key});

  @override
  _PhotoFolderScreenState createState() => _PhotoFolderScreenState();
}

class _PhotoFolderScreenState extends State<PhotoFolderScreen> {
  final TeamManager _teamManager = TeamManager();

  @override
  void initState() {
    super.initState();
    _loadTeamFolders();
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

    // 메인 폴더 생성
    await Directory(teamPath).create(recursive: true);

    // 하위 폴더 생성
    await Directory('$teamPath/전체사진').create(recursive: true);
    await Directory('$teamPath/지역').create(recursive: true);
    await Directory('$teamPath/배경').create(recursive: true);
    await Directory('$teamPath/계절').create(recursive: true);

    // 지역 하위 폴더 생성
    List<String> cities = ['서울', '대전', '부산', '인천', '대구', '울산', '제주도'];
    for (var city in cities) {
      await Directory('$teamPath/지역/$city').create(recursive: true);
    }

    // 배경 하위 폴더 생성
    List<String> backgrounds = ['산', '바다'];
    for (var background in backgrounds) {
      await Directory('$teamPath/배경/$background').create(recursive: true);
    }

    // 계절 하위 폴더 생성
    List<String> seasons = ['봄', '여름', '가을', '겨울'];
    for (var season in seasons) {
      await Directory('$teamPath/계절/$season').create(recursive: true);
    }
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
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: teams.length,
        itemBuilder: (context, index) {
          return _buildGridItem(teams[index].teamName);
        },
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
