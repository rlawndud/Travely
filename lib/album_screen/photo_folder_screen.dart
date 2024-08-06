import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:test2/album_screen/subcategory_screen.dart';
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
  List<String> teamMembers = [];

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
    final String teamPath = '${appDir.path}/${_picManager.getCurrentId()}/$teamName';

    await Directory(teamPath).create(recursive: true);
    await Directory('$teamPath/전체사진').create(recursive: true);
    await Directory('$teamPath/지역').create(recursive: true);
    await Directory('$teamPath/배경').create(recursive: true);
    await Directory('$teamPath/계절').create(recursive: true);
    await Directory('$teamPath/멤버').create(recursive: true);

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
    teamMembers = _findTeamMemberByName(teamName);
    for (var name in teamMembers){
      await Directory('$teamPath/멤버/$name').create(recursive: true);
    }

  }

  List<String> _findTeamMemberByName(String teamName) {
    // 리스트를 순회하면서 팀 이름이 일치하는 팀을 찾습니다.
    for (var team in _teamManager.getTeamList()) {
      if (team.teamName == teamName) {
        return team.members.map((member) => member['name'] as String).toList();
      }
    }
    return [];
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
            builder: (context) => TeamAlbumScreen(teamName: teamName, teamMembers: teamMembers,),
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
  final List<String> teamMembers;

  TeamAlbumScreen({Key? key, required this.teamName, required this.teamMembers}) : super(key: key);

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
          _buildAlbumTile(context, '멤버'),
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
              teamMembers: teamMembers,
            ),
          ),
        );
      },
    );
  }
}



