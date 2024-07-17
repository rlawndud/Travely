import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test2/TeamSearch.dart';
import 'package:test2/FriendAdd.dart';
import 'package:test2/Setting.dart';
import 'package:test2/image_upload_page.dart';
import 'package:test2/TeamSettingScreen.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  String? _teamName = '팀 미설정';

  static List<Widget> _pages = <Widget>[
    const TeamSearchPage(),
    const FriendAddPage(),
    const SettingsPage(),
    const Center(child: Text('팀')),
    const Center(child: Text('앨범')),
    GoogleMapSample(), // 구글 지도 위젯으로 변경
    const Center(child: Text('촬영')),
    const ImageUploadPage(),
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
          title: const Text('Snap Note'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => _onItemTapped(1),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
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
              tabs: const [
                Tab(icon: Icon(Icons.group, color: Colors.black), text: '팀'),
                Tab(icon: Icon(Icons.photo_album, color: Colors.black), text: '앨범'),
                Tab(icon: Icon(Icons.home, color: Colors.black), text: '홈'),
                Tab(icon: Icon(Icons.camera_alt, color: Colors.black), text: '촬영'),
                Tab(
                  child: Image(
                    image: AssetImage('assets/SN Logo.jpg'),
                    height: 30,
                  ),
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
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: const Text('팀 설정'),
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
          child: const Icon(Icons.group),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: Home(),
  ));
}

class GoogleMapSample extends StatefulWidget {
  @override
  _GoogleMapSampleState createState() => _GoogleMapSampleState();
}

class _GoogleMapSampleState extends State<GoogleMapSample> {
  late GoogleMapController _controller;

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
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
              target: LatLng(37.5665, 126.978), // 구글 지도의 LatLng 사용
              zoom: 11.0,
            ),
            zoomControlsEnabled: false, // 기본 줌 컨트롤 비활성화
          ),
          Positioned(
            top: 50,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _zoomIn,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  mini: true,
                  child: Icon(Icons.add),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _zoomOut,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  mini: true,
                  child: Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
