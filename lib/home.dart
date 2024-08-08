import 'dart:async';

import 'package:flutter/material.dart';
import 'package:test2/appbar/friend/Friend.dart';
import 'package:test2/appbar/mypage/My_Page.dart';
import 'package:test2/Settings.dart';
import 'package:test2/model/member.dart';
import 'package:test2/model/imgtest.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test2/image_upload_page.dart';
import 'package:test2/model/team.dart';
import 'package:test2/network/web_socket.dart';
import 'package:test2/album_screen/photo_folder_screen.dart';
import 'package:test2/team_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test2/value/label_markers.dart' as b;

import 'model/picture.dart';

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
    _teamManager = TeamManager();
    _picManager = PicManager();
    _initializeManager();
    _teamManager.addListener(_updateUI);
    _pages = <Widget>[
      TeamPage(userId: _user.id),
      const PhotoFolderScreen(), // 앨범 페이지
      GoogleMapSample(userId: _user.id), // 홈 페이지
      const ImageUploadPage(), // 촬영 페이지 //키면 바로 카메라 실행되게
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
              _onItemTapped(index); // 인덱스 그대로 전달
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
  bool _isLogVisible = false;

  Position? _currentPosition;
  late StreamSubscription<Position> _positionStream;
  late Timer _locationUpdateTimer;
  late WebSocketService _webSocketService;

  final LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 10,
  );

  final List<String> _logLines = [];

  @override
  void initState() {
    super.initState();
    _initLocationTracking();
    _webSocketService = WebSocketService();
    _webSocketService.init();
    _startLocationUpdateTimer();
    _startListeningToFriendLocationsIfNeeded();
  }

  Future<void> _initLocationTracking() async {
    final permissionStatus = await _checkLocationPermission();
    if (permissionStatus) {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: _locationSettings,
      ).listen((Position position) {
        setState(() {
          _currentPosition = position;
          _updateMapLocation();
          _sendLocationToServer();
        });
      });
    }
  }

  void _startListeningToFriendLocationsIfNeeded() {
    TeamManager teamManager = TeamManager();
    if (teamManager.currentTeam.isNotEmpty) {
      _listenToFriendLocations();
    } else {
      _initLocationTracking();
    }
  }

  void _startLocationUpdateTimer() {
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 3), (Timer timer) async {
      await _sendLocationToServer();
    });
  }

  Future<void> _sendLocationToServer() async {
    TeamManager teamManager = TeamManager();

    final data = {
      'id': widget.userId,
      'latitude': _currentPosition!.latitude,
      'longitude': _currentPosition!.longitude,
      'teamNo': teamManager.getTeamNoByTeamName(teamManager.currentTeam),
      'teamName': teamManager.currentTeam
    };
    await _webSocketService.transmit(data, 'UpdateLocation');
  }

  Future<void> _listenToFriendLocations() async {
    _webSocketService.responseStream.listen((message) {
      if (message['command'] == 'TeamLocationUpdate') {
        final friendId = message['id'];
        final latitude = message['latitude'];
        final longitude = message['longitude'];
        final teamNo = message['teamNo'];
        final teamName = message['teamName'];

        final MarkerId markerId = MarkerId('$friendId');

        final b.LabelMarker marker = b.LabelMarker(
          label: '팀방: $teamName\n팀원: $friendId',
          markerId: markerId,
          position: LatLng(latitude, longitude),
          backgroundColor: Colors.green
        );

        setState(() {
          _markers.removeWhere((marker) => marker.markerId == markerId);
          _markers.addLabelMarker(marker);
        });
      }
    });
  }

  Future<bool> _checkLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
    }
    return status.isGranted;
  }

  Future<void> _updateMapLocation() async {
    if (_currentPosition != null) {
      final GoogleMapController mapController = await _controller.future;
      final LatLng position = LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      mapController.animateCamera(CameraUpdate.newLatLng(position));

      const MarkerId markerId = MarkerId('current_location');
      final Marker marker = Marker(
        markerId: markerId,
        position: position,
        infoWindow: InfoWindow(
          title: '내 위치',
          snippet: '위도: ${_currentPosition!.latitude}, 경도: ${_currentPosition!.longitude}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );

      setState(() {
        _markers.removeWhere((m) => m.markerId == markerId);
        // _markers.add(marker);
      });
    }
  }

  void _logPosition(Position position) {
    final timeStamp = DateTime.now().toIso8601String();
    final log = '[$timeStamp]\n'
        '위도: ${position.latitude}, 경도: ${position.longitude}';

    setState(() {
      _logLines.add(log);
      _isLogVisible = true;
    });
  }

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
        const SnackBar(content: Text('현재 위치를 사용할 수 없습니다.')),
      );
    }
  }

  @override
  void dispose() {
    _positionStream.cancel();
    _webSocketService.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
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
    _controller.future.then((controller) {
      controller.animateCamera(CameraUpdate.zoomIn());
    });
  }

  void _zoomOut() {
    _controller.future.then((controller) {
      controller.animateCamera(CameraUpdate.zoomOut());
    });
  }

  void _hideLogContent() {
    setState(() {
      if (_isLogVisible) {
        _isLogVisible = false;
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
            initialCameraPosition: const CameraPosition(
              target: LatLng(36.2048, 127.7669),
              zoom: 13.5,
            ),
            zoomControlsEnabled: true,
            markers: _markers,
            onTap: (position) {
              if (_isAddingMarker) {
                _addMarker(position);
              }
              _hideLogContent();
            },
            myLocationEnabled: true,
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
                  child: const Icon(Icons.remove),
                ),
                SizedBox(height: 20),
                FloatingActionButton(
                  onPressed: _toggleAddMarkerMode,
                  backgroundColor: _isAddingMarker ? Colors.green : Colors.blue,
                  child: const Icon(Icons.add_location_alt),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _toggleDeleteMarkerMode,
                  backgroundColor: _isDeletingMarker ? Colors.red : Colors.blue,
                  child: const Icon(Icons.delete),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () {
                    if (_currentPosition != null) {
                      _logPosition(_currentPosition!);
                    }
                  },
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.refresh),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _moveToCurrentLocation,
                  backgroundColor: Colors.blueAccent,
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
          if (_isLogVisible)
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                height: 200,
                child: ListView.builder(
                  itemCount: _logLines.length,
                  itemBuilder: (context, index) {
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
