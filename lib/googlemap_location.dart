import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test2/network/web_socket.dart';
import 'package:test2/value/MapMarker.dart';
import 'package:test2/value/Markergeneration.dart';

import 'model/team.dart';

class GoogleMapLocation extends StatefulWidget {
  final String userId;
  final String userName;

  const GoogleMapLocation._({required this.userId, required this.userName});

  static GoogleMapLocation? _instance;

  factory GoogleMapLocation({required String userId, required String userName}) {
    _instance ??= GoogleMapLocation._(userId: userId, userName: userName);
    return _instance!;
  }

  @override
  _GoogleMapLocationState createState() => _GoogleMapLocationState();
}

class _GoogleMapLocationState extends State<GoogleMapLocation> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Map<MarkerId, int> _markerClickCounts = {};
  final Map<String, LatLng> _friendLocation = {};
  bool _isAddingMarker = false;
  bool _isDeletingMarker = false;
  bool _isLogVisible = false;
  TeamManager teamManager = TeamManager();

  Position? _currentPosition;
  late StreamSubscription<Position> _positionStream;
  late Timer _locationUpdateTimer;
  late WebSocketService _webSocketService;
  StreamSubscription? _friendLocationSubscription;

  final LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 10,
  );

  final List<String> _logLines = [];
  bool _isInitialized = false;

  List<Marker> customMarkers = [];
  List<Marker> mapBitmapsToMarkers(List<Uint8List> bitmaps) {
    bitmaps.asMap().forEach((i, bmp) {
      customMarkers.add(Marker(
        markerId: MarkerId('$i'),
        position: _friendLocation.values.toList()[i], // 마커 위치 수정
        icon: BitmapDescriptor.fromBytes(bmp),
      ));
    });
    return customMarkers;
  }

  @override
  void initState() {
    super.initState();
    if (!_isInitialized) {
      _initializeServices();
    }
  }

  void _initializeServices() {
    _webSocketService = WebSocketService();
    _initLocationTracking();
    _startLocationUpdateTimer();
    _startListeningToFriendLocationsIfNeeded();
    _isInitialized = true;
  }

  Future<void> _initLocationTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission != LocationPermission.denied) {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: _locationSettings,
      ).listen((Position position) {
        if(mounted){
          setState(() {
            _currentPosition = position;
            _updateMapLocation();
            _sendLocationToServer();
          });
        }
      });
    }
  }

  void _startListeningToFriendLocationsIfNeeded() {
    if (teamManager.currentTeam.isNotEmpty) {
      _listenToFriendLocations();
    } else {
      _initLocationTracking();
    }
  }

  void _startLocationUpdateTimer() {
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 3), (Timer timer) async {
      if (mounted) {
        await _sendLocationToServer();
      }
    });
  }

  Future<void> _sendLocationToServer() async {
    if(_currentPosition!=null && mounted){
      final data = {
        'id': widget.userId,
        'name': widget.userName,
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'teamNo': teamManager.getTeamNoByTeamName(teamManager.currentTeam),
        'teamName': teamManager.currentTeam
      };
      await _webSocketService.transmit(data, 'UpdateLocation');
    }
  }

  void _listenToFriendLocations() {
    _friendLocationSubscription = _webSocketService.responseStream.listen((message) {
      if (message['command'] == 'TeamLocationUpdate') {
        final friendId = message['id'];
        final friendName = message['name'];
        final latitude = message['latitude'];
        final longitude = message['longitude'];
        final LatLng position = LatLng(latitude, longitude);

        setState(() {
          _friendLocation[friendId] = position;
          _customarkers();
        });
      }
    });
  }

  void _customarkers() {
    List<Widget> markerWidgetsList = [];
    for (var entry in _friendLocation.entries) {
      final friendId = entry.key;
      final friendName = entry.key;
      final position = entry.value;

      markerWidgetsList.add(MapMarker(name: friendName));
    }

    MarkerGenerator(markerWidgetsList, (bitmaps) {
      setState(() {
        _markers.clear();
        bitmaps.asMap().forEach((i, bmp) {
          final friendName = _friendLocation.keys.toList()[i];
          final position = _friendLocation[friendName]!;
          final markerId = MarkerId(friendName);

          _markers.add(Marker(
            markerId: markerId,
            position: position,
            icon: BitmapDescriptor.fromBytes(bmp),
          ));
        });
      });
    }).generate(context);
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

  @override
  void dispose() {
    _positionStream.cancel();
    super.dispose();
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
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            initialCameraPosition: const CameraPosition(
              target: LatLng(36.2048, 127.7669),
              zoom: 13.5,
            ),
            zoomControlsEnabled: true,
            myLocationEnabled: true,
            markers: _markers,
            onTap: (position) {
              if (_isAddingMarker) {
                _addMarker(position);
              }
              _hideLogContent();
            },
          ),
          Positioned(
            top: 50,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    if (_currentPosition != null) {
                      _logPosition(_currentPosition!);
                    }
                  },
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.wrap_text_outlined),
                ),
                SizedBox(height: 6),
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
