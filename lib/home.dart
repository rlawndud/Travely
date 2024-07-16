// home.dart

import 'package:flutter/material.dart';
import 'package:test2/TeamSearch.dart';
import 'package:test2/FriendAdd.dart';
import 'package:test2/Setting.dart';
import 'package:test2/image_upload_page.dart';
import 'package:test2/TeamSettingScreen.dart'; // 팀 설정 화면 추가

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  String? _teamName = '팀 미설정'; // 초기 팀 이름 설정

  static const List<Widget> _pages = <Widget>[
    const TeamSearchPage(),
    const FriendAddPage(),
    const SettingsPage(),
    Center(child: Text('팀')),
    Center(child: Text('앨범')),
    Center(child: Text('홈')),
    Center(child: Text('촬영')),
    ImageUploadPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openTeamSettingScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TeamSettingScreen()),
    );
    if (result != null && result is String) {
      setState(() {
        _teamName = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snap Note',
      theme: ThemeData(primaryColor: Colors.white),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Snap Note'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.person_add),
              onPressed: () => _onItemTapped(1),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => _onItemTapped(2),
            ),
          ],
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: DefaultTabController(
          length: 5,
          child: Scaffold(
            body: TabBarView(
              children: _pages.sublist(3),
            ),
            bottomNavigationBar: TabBar(
              onTap: (index) {
                _onItemTapped(index + 3);
              },
              tabs: [
                Tab(icon: Icon(Icons.group, color: Colors.black), text: '팀'),
                Tab(icon: Icon(Icons.photo_album, color: Colors.black), text: '앨범'),
                Tab(icon: Icon(Icons.home, color: Colors.black), text: '홈'),
                Tab(icon: Icon(Icons.camera_alt, color: Colors.black), text: '촬영'),
                Tab(
                  child: Image.asset('assets/SN Logo.jpg', height: 30),
                ),
              ],
            ),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                child: Text(
                  _teamName ?? '팀 미설정',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: Text('팀 설정'),
                onTap: () {
                  _openTeamSettingScreen();
                },
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _openTeamSettingScreen();
          },
          child: Icon(Icons.group),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}