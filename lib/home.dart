import 'dart:async';

import 'package:flutter/material.dart';
import 'package:test2/appbar/friend/Friend.dart';
import 'package:test2/appbar/mypage/My_Page.dart';
import 'package:test2/appbar/Settings.dart';
import 'package:test2/camera_screen.dart';
import 'package:test2/googlemap_image.dart';
import 'package:test2/model/imgtest.dart';
import 'package:test2/model/member.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test2/model/picture.dart';
import 'package:test2/album_screen/photo_folder_screen.dart';
import 'package:test2/team_page.dart';
import 'package:test2/util/permission.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'model/image_marker_cluster.dart';
import 'model/memberImg.dart';
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
      GoogleMapCluster(), // 홈 페이지
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
}


class GoogleMapSample extends StatefulWidget {
  @override
  _GoogleMapSampleState createState() => _GoogleMapSampleState();
}

class _GoogleMapSampleState extends State<GoogleMapSample> {
  late GoogleMapController _controller;
  Set<Marker> _markers = {};
  List<PictureEntity> pics = PicManager().getPictureList();
  double _clusterRadius = 100; // 클러스터 반경 (픽셀 단위)

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  void _createMarkers() async {
    List<List<PictureEntity>> clusters = _clusterPictures(pics);
    for (var cluster in clusters) {
      if (cluster.length == 1) {
        final marker = await _createMarkerFromPic(cluster[0]);
        setState(() {
          _markers.add(marker);
        });
      } else {
        final marker = await _createClusterMarker(cluster);
        setState(() {
          _markers.add(marker);
        });
      }
    }
  }

  List<List<PictureEntity>> _clusterPictures(List<PictureEntity> pictures) {
    List<List<PictureEntity>> clusters = [];
    for (var pic in pictures) {
      bool added = false;
      for (var cluster in clusters) {
        if (_isNearby(pic, cluster[0])) {
          cluster.add(pic);
          added = true;
          break;
        }
      }
      if (!added) {
        clusters.add([pic]);
      }
    }
    return clusters;
  }

  bool _isNearby(PictureEntity pic1, PictureEntity pic2) {
    // 실제 구현에서는 위도와 경도를 픽셀 좌표로 변환하여 거리를 계산해야 합니다.
    // 여기서는 단순화를 위해 위도와 경도의 차이를 사용합니다.
    return (pic1.latitude - pic2.latitude).abs() < 0.01 &&
        (pic1.longitude - pic2.longitude).abs() < 0.01;
  }

  Future<Marker> _createMarkerFromPic(PictureEntity pic) async {
    final icon = await _getMarkerBitmap(75, pictureData: pic.img_data);
    return Marker(
      markerId: MarkerId(pic.img_num.toString()),
      position: LatLng(pic.latitude, pic.longitude),
      icon: icon,
      onTap: () {
        print('Tapped on image ${pic.img_num}');
      },
    );
  }

  Future<Marker> _createClusterMarker(List<PictureEntity> cluster) async {
    final center = _getClusterCenter(cluster);
    final icon = await _getMarkerBitmap(100, text: cluster.length.toString());
    return Marker(
      markerId: MarkerId('cluster_${center.latitude}_${center.longitude}'),
      position: center,
      icon: icon,
      onTap: () {
        print('Tapped on cluster with ${cluster.length} images');
      },
    );
  }

  LatLng _getClusterCenter(List<PictureEntity> cluster) {
    double lat = 0, lng = 0;
    for (var pic in cluster) {
      lat += pic.latitude;
      lng += pic.longitude;
    }
    return LatLng(lat / cluster.length, lng / cluster.length);
  }

  Future<BitmapDescriptor> _getMarkerBitmap(int size, {String? pictureData, String? text}) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = Colors.orange;
    final Paint paint2 = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);

    if (pictureData != null) {
      final ui.Image image = await _base64ToImage(pictureData);
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(size / 2.8, size / 2.8, size / 1.4, size / 1.4),
        Paint(),
      );
    } else {
      canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);
    }

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(fontSize: size / 3, color: Colors.white, fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  Future<ui.Image> _base64ToImage(String base64String) async {
    final Uint8List bytes = BytesToImage(base64String);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(36.2048, 127.7669),
          zoom: 7.0,
        ),
        markers: _markers,
      ),
    );
  }
}