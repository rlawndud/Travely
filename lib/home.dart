import 'dart:async';

import 'package:flutter/material.dart';
import 'package:test2/appbar/friend/Friend.dart';
import 'package:test2/appbar/mypage/My_Page.dart';
import 'package:test2/appbar/Settings.dart';
import 'package:test2/camera_screen.dart';
import 'package:test2/googlemap_image.dart';
import 'package:test2/googlemap_location.dart';
import 'package:test2/model/imgtest.dart';
import 'package:test2/model/locationMarker.dart';
import 'package:test2/model/member.dart';
import 'package:test2/model/picture.dart';
import 'package:test2/album_screen/photo_folder_screen.dart';
import 'package:test2/team_page.dart';
import 'package:test2/util/permission.dart';
import 'model/team.dart';

class Home extends StatefulWidget {
  final Member user;
  const Home({super.key, required this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Member _user;
  late TeamManager _teamManager;
  late PicManager _picManager;
  String _selectedMapType = '앨범';

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _checkPermissions();
    _teamManager = TeamManager();
    _picManager = PicManager();
    _initializeManager();
    _teamManager.addListener(_updateUI);
    _pages = <Widget>[
      TeamPage(userId: _user.id),
      const PhotoFolderScreen(), // 앨범 페이지
      _buildMapWidget(), // 홈 페이지-지도
      CameraScreen(), // 촬영 페이지
    ];
  }

  @override
  void dispose() {
    _teamManager.removeListener(_updateUI);
    super.dispose();
  }

  void _updateUI() {
    setState(() {});  // UI 갱신
    print('home : ${LocationManager().done}');
  }

  Future<void> _checkPermissions() async {
    await PermissionManager.checkAndRequestPermissions();
  }

  Future<void> _initializeManager() async {
    await _teamManager.initialize(_user.id);
    await _picManager.initialize(_user.id);
    setState(() {});
  }

  int _selectedIndex = 0;
  late List<Widget> _pages;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travely',
      theme: ThemeData(primaryColor: Colors.white),
      home: DefaultTabController(
        length: 4, // Tab의 개수에 맞게 수정
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Travely',
                style: TextStyle(
                  fontFamily: 'Agro',
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                )),
            centerTitle: true,
            elevation: 0.0,
            backgroundColor: Colors.pinkAccent[200],
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _onItemTapped(1),
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                UserAccountsDrawerHeader(
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: AssetImage('assets/cat.jpg'),
                  ),
                  accountName: _teamManager.currentTeam.isNotEmpty?Text('${_teamManager.currentTeam}',style: TextStyle(fontWeight: FontWeight.bold),)
                      :Text('현재 설정된 팀이 없음'),
                  accountEmail: Text('${_user.id}'),
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent[100],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0),
                    ),
                  ),
                  onDetailsPressed: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  iconColor: Colors.black38,
                  focusColor: Colors.black38,
                  title: const Text('My Page'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyPage()),
                    );
                  },
                  trailing: const Icon(Icons.navigate_next),
                ),
                ListTile(
                  leading: const Icon(Icons.group),
                  iconColor: Colors.black38,
                  focusColor: Colors.black38,
                  title: const Text('Friend'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Friend()),
                    );
                  },
                  trailing: const Icon(Icons.navigate_next),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  iconColor: Colors.black38,
                  focusColor: Colors.black38,
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage(user: _user,)), // 여기 수정
                    );
                  },
                  trailing: const Icon(Icons.navigate_next),
                ),
                ListTile(
                  leading: const Icon(Icons.question_answer),
                  iconColor: Colors.black38,
                  focusColor: Colors.black38,
                  title: const Text('도움말'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => album(id: _user.id,)), // 여기 수정
                    );
                  },
                  trailing: const Icon(Icons.navigate_next),
                ),
              ],
            ),
          ),
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: _pages, // 전체 리스트를 참조
          ),
          bottomNavigationBar: TabBar(
            onTap: (index) {
              _onItemTapped(index);
            },
            tabs: const [
              Tab(icon: Icon(Icons.group, color: Colors.black), text: '팀'),
              Tab(icon: Icon(Icons.photo_album, color: Colors.black), text: '앨범'),
              Tab(icon: Icon(Icons.home, color: Colors.black), text: '홈'),
              Tab(icon: Icon(Icons.camera_alt, color: Colors.black), text: '촬영'),
              //Tab(icon: Icon(Icons.edit_note, color: Colors.black),
              //text: 'SnapNote',
              //),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapWidget() {
    return Stack(
      children: [
        _selectedMapType == '앨범' ? GoogleMapCluster() : GoogleMapLocation(userId: _user.id),
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButton<String>(
              value: _selectedMapType,
              items: ['앨범', 'GPS']
                  .map((String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ))
                  .toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  print(newValue);
                  setState(() {
                    _selectedMapType = newValue;
                    _pages[2] = _buildMapWidget();
                  });
                }
              },
              underline: Container(),
            ),
          ),
        ),
      ],
    );
  }

}