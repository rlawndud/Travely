import 'package:flutter/material.dart';
import 'package:test2/appbar/friend/Friend.dart';
import 'package:test2/appbar/mypage/My_Page.dart';
import 'package:test2/appbar/Settings.dart';
import 'package:test2/camera_screen.dart';
import 'package:test2/model/imgtest.dart';
import 'package:test2/model/member.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
      GoogleMapSample(), // 홈 페이지
      CameraScreen(), // 촬영 페이지 //키면 바로 카메라 실행되게
    ];
  }

  @override
  void dispose() {
    _teamManager.removeListener(_updateUI);
    super.dispose();
  }

  void _updateUI() {
    setState(() {});  // UI 갱신
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
                  leading: Icon(Icons.person),
                  iconColor: Colors.black38,
                  focusColor: Colors.black38,
                  title: Text('My Page'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyPage()),
                    );
                  },
                  trailing: Icon(Icons.navigate_next),
                ),
                ListTile(
                  leading: Icon(Icons.group),
                  iconColor: Colors.black38,
                  focusColor: Colors.black38,
                  title: Text('Friend'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Friend()),
                    );
                  },
                  trailing: Icon(Icons.navigate_next),
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  iconColor: Colors.black38,
                  focusColor: Colors.black38,
                  title: Text('Settings'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage(user: _user,)), // 여기 수정
                    );
                  },
                  trailing: Icon(Icons.navigate_next),
                ),
                ListTile(
                  leading: Icon(Icons.question_answer),
                  iconColor: Colors.black38,
                  focusColor: Colors.black38,
                  title: Text('도움말'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => album(id: _user.id,)), // 여기 수정
                    );
                  },
                  trailing: Icon(Icons.navigate_next),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: _pages, // 전체 리스트를 참조
          ),
          bottomNavigationBar: TabBar(
            onTap: (index) {
              print(index);
              if(index == 3){
                if(_teamManager.currentTeam.isNotEmpty){
                  _onItemTapped(index);
                }
              }else{
                _onItemTapped(index); // 인덱스 그대로 전달
              }
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
}


class GoogleMapSample extends StatefulWidget {
  @override
  _GoogleMapSampleState createState() => _GoogleMapSampleState();
}

class _GoogleMapSampleState extends State<GoogleMapSample> {
  late GoogleMapController _controller;
  final Set<Marker> _markers = {};
  final Map<MarkerId, int> _markerClickCounts = {};
  bool _isAddingMarker = false;
  bool _isDeletingMarker = false;

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  void _toggleAddMarkerMode() {
    setState(() {
      _isAddingMarker = !_isAddingMarker;
      if (_isAddingMarker) _isDeletingMarker = false;
    });
  }

  void _toggleDeleteMarkerMode() {
    setState(() {
      _isDeletingMarker = !_isDeletingMarker;
      if (_isDeletingMarker) _isAddingMarker = false;
    });
  }

  void _addMarker(LatLng position) {
    setState(() {
      final markerId = MarkerId(position.toString());
      if (!_markerClickCounts.containsKey(markerId)) {
        _markerClickCounts[markerId] = 0;
      }
      final marker = Marker(
        markerId: markerId,
        position: position,
        infoWindow: InfoWindow(
          title: 'Custom Location',
          snippet: '${position.latitude}, ${position.longitude}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _markerClickCounts[markerId]! > 5 ? BitmapDescriptor.hueRed : BitmapDescriptor.hueBlue,
        ),
        onTap: () {
          if (_isDeletingMarker) {
            _removeMarker(markerId);
          } else {
            _incrementMarkerClickCount(markerId);
          }
        },
      );
      _markers.add(marker);
    });
  }

  void _removeMarker(MarkerId markerId) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId == markerId);
      _markerClickCounts.remove(markerId);
    });
  }

  void _incrementMarkerClickCount(MarkerId markerId) {
    setState(() {
      _markerClickCounts[markerId] = _markerClickCounts[markerId]! + 1;
      final updatedMarker = _markers.firstWhere((marker) => marker.markerId == markerId);
      _markers.remove(updatedMarker);
      _markers.add(updatedMarker.copyWith(
        iconParam: BitmapDescriptor.defaultMarkerWithHue(
          _markerClickCounts[markerId]! > 5 ? BitmapDescriptor.hueRed : BitmapDescriptor.hueBlue,
        ),
      ));
    });
  }

  void _zoomIn() {
    _controller.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _controller.animateCamera(CameraUpdate.zoomOut());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(36.2048, 127.7669),
              zoom: 7.0,
            ),
            zoomControlsEnabled: false,
            markers: _markers,
            onTap: (position) {
              if (_isAddingMarker) {
                _addMarker(position);
              }
            },
          ),
          Positioned(
            top: 50,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _zoomIn,
                  mini: true,
                  heroTag: null,
                  child: Icon(Icons.add),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _zoomOut,
                  mini: true,
                  heroTag: null,
                  child: Icon(Icons.remove),
                ),
                SizedBox(height: 20),
                FloatingActionButton(
                  onPressed: _toggleAddMarkerMode,
                  backgroundColor: _isAddingMarker ? Colors.green : Colors.blue,
                  child: Icon(Icons.add_location_alt),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _toggleDeleteMarkerMode,
                  backgroundColor: _isDeletingMarker ? Colors.red : Colors.blue,
                  child: Icon(Icons.delete),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
