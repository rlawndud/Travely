import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:test2/network/web_socket.dart';
import 'package:test2/value/MapMarker.dart';

import 'model/team.dart';
import 'value/Markergeneration.dart';

class GoogleMapLocation extends StatefulWidget {
  final String userId;
  final String userName;

  const GoogleMapLocation({super.key, required this.userId, required this.userName});

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

  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  StreamSubscription<dynamic>? _friendLocationStream;
  late Timer _locationUpdateTimer;
  late WebSocketService _webSocketService;

  final LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 10,
  );

  final List<String> _logLines = [];
  final Map<String, String> _friendName = {};

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
    LocationPermission permissionStatus = await Geolocator.checkPermission();
    if (permissionStatus == LocationPermission.denied) {
      permissionStatus = await Geolocator.requestPermission();
    }
    if (permissionStatus != LocationPermission.denied) {
      _positionStream = Geolocator.getPositionStream(locationSettings: _locationSettings).listen((Position position) {
        if (mounted) {
          _updateCurrentPosition(position);
        }
      });
    }
  }

  void _updateCurrentPosition(Position position) {
    setState(() {
      _currentPosition = position;
      _updateMapLocation();
      _sendLocationToServer();
    });
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
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _sendLocationToServer();
    });
  }

  Future<void> _sendLocationToServer() async {
    if (_currentPosition != null) {
      TeamManager teamManager = TeamManager();
      final data = {
        'id': widget.userId,
        'name': widget.userName,
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'teamNo': teamManager.getTeamNoByTeamName(teamManager.currentTeam),
        'teamName': teamManager.currentTeam,
      };
      await _webSocketService.transmit(data, 'UpdateLocation');
    }
  }

  Future<void> _listenToFriendLocations() async {
    _friendLocationStream = _webSocketService.responseStream.listen((message) {
      if (message['command'] == 'TeamLocationUpdate') {
        final friendId = message['id'];
        final friendName = message['userName'];
        final latitude = message['latitude'];
        final longitude = message['longitude'];
        final LatLng position = LatLng(latitude, longitude);

        if (mounted) {
          _updateFriendLocation(friendId, friendName, position);
        }
      }
    });
  }

  void _updateFriendLocation(String friendId, String friendName, LatLng position) {
    setState(() {
      _friendLocation[friendId] = position;
      _friendName[friendId] = friendName;
      _customarkers();
    });
  }

  void _customarkers() {
    final markerWidgetsList = _friendLocation.entries.map((entry) {
      final friendName = _friendName[entry.key];
      return MapMarker(name: friendName!);
    }).toList();

    MarkerGenerator(markerWidgetsList, (bitmaps) {
      setState(() {
        _markers.clear();
        bitmaps.asMap().forEach((i, bmp) {
          final friendId = _friendLocation.keys.toList()[i];
          final friendName = _friendName[friendId]!;
          final position = _friendLocation[friendId]!;
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
      final mapController = await _controller.future;
      final position = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

      mapController.animateCamera(CameraUpdate.newLatLng(position));

      setState(() {
        const markerId = MarkerId('current_location');
        _markers.removeWhere((m) => m.markerId == markerId);
      });
    }
  }

  void _logPosition(Position position) {
    final timeStamp = DateTime.now().toIso8601String();
    final log = '[$timeStamp]\n위도: ${position.latitude}, 경도: ${position.longitude}';

    setState(() {
      _logLines.add(log);
      _isLogVisible = true;
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _friendLocationStream?.cancel();
    _locationUpdateTimer.cancel();
    super.dispose();
  }

  void _addMarker(LatLng position) {
    final markerId = MarkerId(position.toString());
    setState(() {
      _markerClickCounts[markerId] ??= 0;
      _markers.add(Marker(
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
      ));
    });
  }

  void _removeMarker(MarkerId markerId) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId == markerId);
      _markerClickCounts.remove(markerId);
    });
  }

  void _incrementMarkerClickCount(MarkerId markerId) {
    final count = _markerClickCounts[markerId] = _markerClickCounts[markerId]! + 1;
    final hue = count > 5 ? BitmapDescriptor.hueRed : BitmapDescriptor.hueBlue;

    setState(() {
      final marker = _markers.firstWhere((marker) => marker.markerId == markerId);
      _markers.remove(marker);
      _markers.add(marker.copyWith(iconParam: BitmapDescriptor.defaultMarkerWithHue(hue)));
    });
  }

  void _hideLogContent() {
    if (_isLogVisible) {
      setState(() {
        _isLogVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _controller.complete(controller),
            initialCameraPosition: const CameraPosition(
              target: LatLng(36.3360, 127.4454),
              zoom: 17,
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
                const SizedBox(height: 6),
              ],
            ),
          ),
          if (_isLogVisible)
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.white,
                height: 200,
                child: ListView.builder(
                  itemCount: _logLines.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(
                      _logLines[index],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}