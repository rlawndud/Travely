import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:test2/appbar/friend/Friend.dart';
import 'package:test2/appbar/mypage/My_Page.dart';
import 'package:test2/appbar/Settings.dart';
import 'package:test2/camera_screen.dart';
import 'package:test2/map_page.dart';
import 'package:test2/model/locationMarker.dart';
import 'package:test2/model/member.dart';
import 'package:test2/model/picture.dart';
import 'package:test2/album_screen/photo_folder_screen.dart';
import 'package:test2/network/web_socket.dart';
import 'package:test2/search_page.dart';
import 'package:test2/team_page.dart';
import 'package:test2/util/permission.dart';
import 'package:test2/value/color.dart';
import 'package:test2/model/team.dart';
import 'package:test2/value/global_variable.dart';

class Home extends StatefulWidget {
  final Member user;
  const Home({super.key, required this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  late Member _user;
  final TeamManager _teamManager = TeamManager();
  final PicManager _picManager = PicManager();
  bool _isSearchMode = false;
  int _previouseIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  late SearchPage _searchPage;


  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _checkPermissions();
    _initializeManager();
    _teamManager.addListener(_updateUI);
    _searchPage = SearchPage(initialQuery: '');
    _pages = <Widget>[
      TeamPage(userId: _user.id),
      const PhotoFolderScreen(), // 앨범 페이지
      MapPage(userId: _user.id, userName: _user.name), // 홈 페이지-지도
      const CameraScreen(), // 촬영 페이지
    ];
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _teamManager.removeListener(_updateUI);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if(state == AppLifecycleState.detached) {
      print('강종?');
      _logoutSignal();
    }
  }

  Future<void> _logoutSignal() async {
    try{
      await WebSocketService().transmit({'id': _user.id}, 'Logout');
    }catch(e){
      e.printError;
    }
  }

  void _updateUI() {
    setState(() {});  // UI 갱신
    print('home-location : ${LocationManager().done}');
  }

  Future<void> _checkPermissions() async {
    await PermissionManager.checkAndRequestPermissions();
  }

  Future<void> _initializeManager() async {
    await _picManager.initialize(_user.id);
    setState(() {});
  }

  int _selectedIndex = 0;
  late List<Widget> _pages;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_isSearchMode) {
        _isSearchMode = false;
        _searchController.clear();
      }
    });
  }

  void _performSearch(String query){
    print('홈 perfomSearch $query');
    setState(() {
      _isSearchMode = true;
      _previouseIndex = _selectedIndex;
      _searchPage = SearchPage(initialQuery: query);
    });
  }

  Future<bool> _showBackDialog() async{
    if (GlobalVariable.homeScaffoldKey.currentState!.isDrawerOpen) {
      GlobalVariable.homeScaffoldKey.currentState!.closeDrawer();
      return false;
    } else {
      return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('앱 종료'),
          content: Text('정말로 앱을 종료하시겠습니까?'),
          actions: [
            SizedBox(
              width: 80,
              height: 40,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: Text('취소'),
              ),
            ),
            SizedBox(
              width: 80,
              height: 40,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                ),
                child: Text('종료'),
              ),
            ),
          ],
        ),
      ) ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if(didPop){
          return;
        }
        final shouldPop = await _showBackDialog();
        if(shouldPop){
          await _logoutSignal();
          dispose();
          SystemNavigator.pop();
        }
      },
      child: DefaultTabController(
        length: 4, // Tab의 개수에 맞게 수정
        child: Scaffold(
          key: GlobalVariable.homeScaffoldKey,
          appBar: AppBar(
            title: _isSearchMode ? TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '사진에 대한 검색어를 입력해주세요',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: TextStyle(color: Colors.white),
              autofocus: true,
              onSubmitted: (value) {
                _performSearch(value);
              },
            )
                : const Text('Travely',
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
                icon: Icon(_isSearchMode ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    if (_isSearchMode) {
                      if (_searchController.text.isNotEmpty) {
                        // 검색어가 있을 경우, 입력창을 비움
                        _searchController.clear();
                        _performSearch('');
                      } else {
                        // 검색어가 없을 경우, 검색 모드를 종료하고 원래 페이지로
                        _isSearchMode = false;
                        _selectedIndex = _previouseIndex;
                      }
                    } else {
                      // 검색 모드가 아닐 때, 검색 모드로 전환
                      _isSearchMode = true;
                      _previouseIndex = _selectedIndex;
                    }
                  });
                },
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
                  accountName: _teamManager.currentTeam.isNotEmpty
                      ? Text('${_teamManager.currentTeam}', style: TextStyle(fontWeight: FontWeight.bold),)
                      : Text('현재 설정된 팀이 없음'),
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
                      MaterialPageRoute(builder: (context) => MyPage(user: _user)),
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
                      MaterialPageRoute(
                        builder: (context) => Friend(user: _user,),
                      ),
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
                      MaterialPageRoute(builder: (context) => SettingsPage(user: _user,)),
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
                    // 도움말 컨텐츠 추가 필요
                  },
                  trailing: const Icon(Icons.navigate_next),
                ),
              ],
            ),
          ),
          body: _isSearchMode
          ? _searchPage
          : TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: _pages,
          ),
          bottomNavigationBar: Material(
            color: Colors.white,
            child: TabBar(
              onTap: (index) {
                _onItemTapped(index);
              },
              tabs: const [
                Tab(icon: Icon(Icons.group, color: Colors.black), text: '팀'),
                Tab(icon: Icon(Icons.photo_album, color: Colors.black), text: '앨범'),
                Tab(icon: Icon(Icons.home, color: Colors.black), text: '홈'),
                Tab(icon: Icon(Icons.camera_alt, color: Colors.black), text: '촬영'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}