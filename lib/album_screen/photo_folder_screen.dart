import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:travley/album_screen/subcategory_screen.dart';
import 'package:travley/model/picture.dart';
import 'package:travley/model/team.dart';
import 'package:travley/search_page.dart';

class PhotoFolderScreen extends StatefulWidget {
  const PhotoFolderScreen({super.key});

  @override
  _PhotoFolderScreenState createState() => _PhotoFolderScreenState();
}

class _PhotoFolderScreenState extends State<PhotoFolderScreen> {
  final TeamManager _teamManager = TeamManager();
  final PicManager _picManager = PicManager();
  List<TeamEntity> teams = [];

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
    teams = _teamManager.getTeamList();
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
    await Directory('$teamPath/계절').create(recursive: true);
    await Directory('$teamPath/멤버').create(recursive: true);
    await Directory('$teamPath/멤버').create(recursive: true);

    List<String> cities = ['서울', '대전', '부산', '인천', '대구', '울산', '광주', '제주도', '기타 지역'];
    for (var city in cities) {
      await Directory('$teamPath/지역/$city').create(recursive: true);
    }

    List<String> seasons = ['봄', '여름', '가을', '겨울'];
    for (var season in seasons) {
      await Directory('$teamPath/계절/$season').create(recursive: true);
    }

    TeamEntity team = teams.firstWhere((t) => t.teamName == teamName);
    for (var member in team.members) {
      await Directory('$teamPath/멤버/${member['name']}').create(recursive: true);
    }
    print('${team.teamName} : ${team.members}');

  }

  @override
  Widget build(BuildContext context) {

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
            builder: (context) => TeamAlbumScreen(teamName: teamName, teamMembers: teams[index].members,),
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
  final List<Map<String, dynamic>> teamMembers;

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                _buildAlbumTile(context, '계절'),
                _buildAlbumTile(context, '멤버'),
                _buildAlbumTile(context, '촬영자'),
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



