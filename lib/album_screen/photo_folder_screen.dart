import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:test2/album_screen/subcategory_screen.dart';
import 'package:test2/model/picture.dart';
import 'package:test2/model/team.dart';
import 'package:test2/search_page.dart';

class PhotoFolderScreen extends StatefulWidget {
  const PhotoFolderScreen({super.key});

  @override
  _PhotoFolderScreenState createState() => _PhotoFolderScreenState();
}

class _PhotoFolderScreenState extends State<PhotoFolderScreen> {
  final TeamManager _teamManager = TeamManager();
  final PicManager _picManager = PicManager();
  List<dynamic> team_teamMembers = [];
  List<String> teamMembers = [];

  @override
  void initState() {
    super.initState();
    _loadTeamFolders();
  }

  @override
  void dispose() {
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
    // await Directory('$teamPath/배경').create(recursive: true);
    await Directory('$teamPath/계절').create(recursive: true);
    await Directory('$teamPath/멤버').create(recursive: true);

    List<String> cities = ['서울', '대전', '부산', '인천', '대구', '울산', '광주', '제주도', '기타 지역'];
    for (var city in cities) {
      await Directory('$teamPath/지역/$city').create(recursive: true);
    }

    // List<String> backgrounds = ['산', '바다', '기타'];
    // for (var background in backgrounds) {
    //   await Directory('$teamPath/배경/$background').create(recursive: true);
    // }

    List<String> seasons = ['봄', '여름', '가을', '겨울'];
    for (var season in seasons) {
      await Directory('$teamPath/계절/$season').create(recursive: true);
    }
    teamMembers = _findTeamMemberByName(teamName);
    team_teamMembers.add(teamMembers);
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

  /*void _subscribeToNewImages() {
    _picSubscription = _picManager.imageStream.listen((newImage) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('새로운 사진이 추가되었습니다: ${newImage.img_num}'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }*/

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
          return _buildTeamItem(teams[index].teamName, index);
        },
      ),
    );
  }

  Widget _buildTeamItem(String teamName, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeamAlbumScreen(teamName: teamName, teamMembers: team_teamMembers[index],),
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


class TeamAlbumScreen extends StatefulWidget {
  final String teamName;
  final List<String> teamMembers;

  TeamAlbumScreen({Key? key, required this.teamName, required this.teamMembers}) : super(key: key);

  @override
  _TeamAlbumScreenState createState() => _TeamAlbumScreenState();
}

class _TeamAlbumScreenState extends State<TeamAlbumScreen> {
  bool _isSearchMode = false;
  final TextEditingController _searchController = TextEditingController();
  late SearchPage _searchPage;
  late int _teamNo;

  @override
  void initState() {
    super.initState();
    _initializeTeamNo();
    _searchPage = SearchPage(initialQuery: '', teamNo: _teamNo);
  }

  void _initializeTeamNo() {
    final teamManager = TeamManager();
    _teamNo = teamManager.getTeamNoByTeamName(widget.teamName) ?? -1;
    if (_teamNo == -1) {
      print('Error: 팀 번호를 찾을 수 없습니다.');
    }
  }

  void _performSearch(String query) {
    setState(() {
      _isSearchMode = true;
      _searchPage = SearchPage(initialQuery: query, teamNo: _teamNo);
    });
  }
  @override
  Widget build(BuildContext context) {
    print('TeamAlbumScreen : ${widget.teamName}, ${widget.teamMembers.toString()}');
    return Scaffold(
      appBar: AppBar(
        title: _isSearchMode
            ? TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '${widget.teamName} 팀 사진 검색',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white),
          autofocus: true,
          onSubmitted: (value) {
            _performSearch(value);
          },
        )
        : Text('${widget.teamName} 팀 앨범'),
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(
            icon: Icon(_isSearchMode ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearchMode) {
                  if (_searchController.text.isNotEmpty) {
                    _searchController.clear();
                    _performSearch('');
                  } else {
                    _isSearchMode = false;
                  }
                } else {
                  _isSearchMode = true;
                }
              });
            },
          ),
        ],
      ),
      body: _isSearchMode
          ? _searchPage
          : ListView(
              children: [
                _buildAlbumTile(context, '전체사진'),
                _buildAlbumTile(context, '지역'),
                // _buildAlbumTile(context, '배경'),
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
              teamName: widget.teamName,
              category: category,
              teamMembers: widget.teamMembers,
            ),
          ),
        );
      },
    );
  }
}



