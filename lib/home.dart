import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test2/appbar/friend/Friend.dart';
import 'package:test2/appbar/mypage/My_Page.dart';
import 'package:test2/Settings.dart';
import 'package:test2/model/member.dart';
import 'package:test2/model/imgtest.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test2/image_upload_page.dart';
import 'package:test2/network/web_socket.dart';
import 'package:test2/photo_folder_screen.dart';
import 'package:test2/team_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  final Member user;
  const Home({super.key, required this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Member _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _pages = <Widget>[
      TeamPage(userId: _user.id,),
      const PhotoFolderScreen(), // 앨범 페이지
      GoogleMapSample(userId: _user.id), // 홈 페이지
      const ImageUploadPage(), // 촬영 페이지
    ];
  }

  int _selectedIndex = 0;
  String? _teamName = '팀 미설정';
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
            title: const Text('travely',
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  fontSize: 22,
                  fontWeight: FontWeight.normal,
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
                  accountName: Text('R 2 B'),
                  accountEmail: Text('abc12345@naver.com'),
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
                      MaterialPageRoute(builder: (context) => album()), // 여기 수정
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
              _onItemTapped(index); // 인덱스 그대로 전달
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
  final String userId;
  const GoogleMapSample({super.key, required this.userId});

  @override
  _GoogleMapSampleState createState() => _GoogleMapSampleState();
}

class _GoogleMapSampleState extends State<GoogleMapSample> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Map<MarkerId, int> _markerClickCounts = {};
  bool _isAddingMarker = false;
  bool _isDeletingMarker = false;
  bool _isLogVisible = false; // 로그 내용 표시 여부를 제어하는 변수 추가

  Position? _currentPosition;
  late StreamSubscription<Position> _positionStream;
  final LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 10,
  );
  String _logContent = ""; // 파일에 저장할 로그 내용
  List<String> _logLines = []; // 로그 항목 리스트

  @override
  void initState() {
    super.initState();
    _initLocationTracking(); // 위치 추적 초기화
  }

  Future<void> _initLocationTracking() async {
    final permissionStatus = await _checkLocationPermission();
    if (permissionStatus) {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: _locationSettings,
      ).listen((Position position) {
        setState(() {
          _currentPosition = position;
          _updateMapLocation(); // 지도 위치 업데이트
          _savePositionToFile(position); // 위치를 파일에 저장
        });
      });
    }
  }

  // 위치 권한을 확인하고 요청하는 함수
  Future<bool> _checkLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
    }
    return status.isGranted;
  }

  // 현재 위치를 기반으로 지도와 마커를 업데이트하는 함수
  Future<void> _updateMapLocation() async {
    if (_currentPosition != null) {
      final GoogleMapController mapController = await _controller.future;
      final LatLng position = LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      //웹소켓으로 위도 경도 보내기
      WebSocketService webSocketService = WebSocketService();
      if (_currentPosition != null) {
        Map<String,dynamic> data = {
          'id': widget.userId,
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude
        };
        webSocketService.transmit(data, 'UpdateLocation');
      }

      // 지도 위치 업데이트
      mapController.animateCamera(
        CameraUpdate.newLatLng(position),
      );

      // 현재 위치를 표시하는 마커 업데이트
      final MarkerId markerId = MarkerId('current_location');
      final Marker marker = Marker(
        markerId: markerId,
        position: position,
        infoWindow: InfoWindow(
          title: 'You are here',
          snippet: 'Latitude: ${_currentPosition!.latitude}, Longitude: ${_currentPosition!.longitude}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );

      setState(() {
        _markers.removeWhere((m) => m.markerId == markerId);
        _markers.add(marker);
      });
    }
  }

  // 위치 정보를 파일에 저장하는 함수
  Future<void> _savePositionToFile(Position position) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/location_log.txt';
    final file = File(path);
    final timeStamp = DateTime.now().toIso8601String();
    final log = '[$timeStamp] Latitude: ${position.latitude}, Longitude: ${position.longitude}\n';

    await file.writeAsString(log, mode: FileMode.append);
  }

  // 파일에서 로그 내용을 읽어와서 화면에 표시하는 함수
  Future<void> _loadLogContent() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/location_log.txt';
    final file = File(path);

    if (await file.exists()) {
      final content = await file.readAsString();
      setState(() {
        _logContent = content;
        _logLines = _logContent.split('\n').where((line) => line.isNotEmpty).toList();
        _isLogVisible = true; // 로그 내용 표시
      });
    } else {
      setState(() {
        _logContent = "No log file found.";
        _logLines = [_logContent];
        _isLogVisible = true; // 로그 내용 표시
      });
    }
  }

  // 현재 위치를 파일에 저장하고 사용자에게 알림을 표시하는 함수
  Future<void> _saveCurrentPosition() async {
    if (_currentPosition != null) {
      await _savePositionToFile(_currentPosition!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Position saved to file!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Current position is not available.')),
      );
    }
  }

  // 현재 위치로 지도를 이동하는 함수
  Future<void> _moveToCurrentLocation() async {
    if (_currentPosition != null) {
      final GoogleMapController mapController = await _controller.future;
      final LatLng position = LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      mapController.animateCamera(CameraUpdate.newLatLng(position));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Current position is not available.')),
      );
    }
  }

  @override
  void dispose() {
    _positionStream.cancel(); // 위치 스트림 구독 취소
    super.dispose();
  }

  // GoogleMap이 생성될 때 호출되는 함수
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  // 마커 추가 모드를 토글하는 함수
  void _toggleAddMarkerMode() {
    setState(() {
      _isAddingMarker = !_isAddingMarker;
      if (_isAddingMarker) _isDeletingMarker = false;
    });
  }

  // 마커 삭제 모드를 토글하는 함수
  void _toggleDeleteMarkerMode() {
    setState(() {
      _isDeletingMarker = !_isDeletingMarker;
      if (_isDeletingMarker) _isAddingMarker = false;
    });
  }

  // 지도에 마커를 추가하는 함수
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
            _removeMarker(markerId); // 마커 삭제
          } else {
            _incrementMarkerClickCount(markerId); // 마커 클릭 수 증가
          }
        },
      );
      _markers.add(marker);
    });
  }

  // 마커를 삭제하는 함수
  void _removeMarker(MarkerId markerId) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId == markerId);
      _markerClickCounts.remove(markerId);
    });
  }

  // 마커의 클릭 수를 증가시키는 함수
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

  // 지도를 확대하는 함수
  void _zoomIn() {
    _controller.future.then((controller) {
      controller.animateCamera(CameraUpdate.zoomIn());
    });
  }

  // 지도를 축소하는 함수
  void _zoomOut() {
    _controller.future.then((controller) {
      controller.animateCamera(CameraUpdate.zoomOut());
    });
  }

  // 지도를 클릭할 때 로그 내용이 표시되어 있을 경우 로그 내용만 숨기는 함수
  void _hideLogContent() {
    setState(() {
      if (_isLogVisible) {
        _isLogVisible = false; // 로그 내용을 숨김
      }
    });
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
              _hideLogContent(); // 지도를 클릭할 때 로그 내용 숨기기
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
                  child: Icon(Icons.add), // 지도를 확대하는 버튼
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _zoomOut,
                  mini: true,
                  heroTag: null,
                  child: Icon(Icons.remove), // 지도를 축소하는 버튼
                ),
                SizedBox(height: 20),
                FloatingActionButton(
                  onPressed: _toggleAddMarkerMode,
                  backgroundColor: _isAddingMarker ? Colors.green : Colors.blue,
                  child: Icon(Icons.add_location_alt), // 마커 추가 버튼
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _toggleDeleteMarkerMode,
                  backgroundColor: _isDeletingMarker ? Colors.red : Colors.blue,
                  child: Icon(Icons.delete), // 마커 삭제 버튼
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _saveCurrentPosition,
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.save), // 현재 위치 저장 버튼
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _loadLogContent,
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.refresh), // 로그 로드 버튼
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _moveToCurrentLocation,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.my_location), // 현재 위치로 이동 버튼
                ),
              ],
            ),
          ),
          // 로그 내용이 표시되어야 할 때만 표시
          if (_isLogVisible)
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                height: 200, // 로그 화면의 높이를 제한하여 2개의 항목만 보이게 함
                child: ListView.builder(
                  itemCount: _logLines.length,
                  itemBuilder: (context, index) {
                    // 모든 로그 항목 표시
                    return ListTile(
                      title: Text(
                        _logLines[index],
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
