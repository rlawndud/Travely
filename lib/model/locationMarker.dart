import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:travley/model/team.dart';
import 'package:travley/network/web_socket.dart';

class LocationMarker{
  String userId;
  String userName;
  double latitude;
  double longitude;
  int teamNo;

  LocationMarker(this.userId, this.userName, this.latitude, this.longitude, this.teamNo);

  factory LocationMarker.fromJson(Map<String, dynamic> json){
    return LocationMarker(
        json['id'] as String,
        json['userName'] as String,
        json['latitude'] as double,
        json['longitude'] as double,
        json['teamNo'] as int,
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': userId,
      'name': userName,
      'latitude': latitude,
      'longitude': longitude,
      'teamNo': teamNo,
    };
  }

  @override
  String toString() {
    return '$userName: ($latitude, $longitude)';
  }
}

//실제 기능에선 사용되지 않고 있음 그러나 제외하면 에러 발생
class LocationManager with ChangeNotifier {
  static final LocationManager _instance = LocationManager._internal();
  final WebSocketService _webSocketService = WebSocketService();
  final TeamManager _teamManager = TeamManager();
  late StreamSubscription<Position> _positionStream;
  final Map<int, List<LocationMarker>> _teamLocations = {};
  static String _currentUserId = '';
  static String _currentUserName = '';
  Timer? _locationUpdateTimer;
  Position? _currentPosition;
  bool _isInitialized = false;
  String done = '';
  final _locationStreamController = StreamController<LocationMarker>.broadcast();
  final LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 10,
  );

  LocationManager._internal();

  factory LocationManager() {
    return _instance;
  }

  Future<void> initialize(String userId, String userName) async {
    if (!_isInitialized || _currentUserId != userId) {
      _currentUserId = userId;
      _currentUserName = userName;
      try{
        await _initLocationTracking(); // 내 위치 전달
        _startLocationUpdateTimer();
        //await _syncLocationOnMap(); // 현재 팀 위치 업데이트(나 포함 전원)
        _isInitialized = true;
      }catch(e){
        debugPrint('LocationManager 초기화 에러 : $e');
      }
    }
  }

  Stream<LocationMarker> get locationStream => _locationStreamController.stream;
  Position? get currentPosition => _currentPosition;

  Future<void> _initLocationTracking() async {

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: _locationSettings,
      ).listen((Position position) async {
        // done = position.latitude.toString();
        _currentPosition = position;
      });
    }
    notifyListeners();
  }


  void _startLocationUpdateTimer() {
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      if (_currentPosition != null) {
        await _sendLocationToServer(_currentPosition!);
      }
    });
  }

  Future<void> _sendLocationToServer(Position position) async {
    String currentTeam = _teamManager.currentTeam;
    if(currentTeam.isNotEmpty){
      int? currentTeamNo = _teamManager.getTeamNoByTeamName(currentTeam);
      if (currentTeamNo != null) {
        final location = LocationMarker(
            _currentUserId,
            _currentUserName,
            position.latitude,
            position.longitude,
            currentTeamNo,
        );
        try{
          await _webSocketService.transmit(location.toJson(), 'UpdateLocation');
          print('서버로 내 위치 정보 전달: ${location.toJson()}');
        }catch(e){
          e.printError;
        }
      }
    }
  }

  void updateLocation(LocationMarker marker) {
    int teamNo = marker.teamNo;
    if(!_teamLocations.containsKey(teamNo)){
      _teamLocations[teamNo] = [];
    }
    int index = _teamLocations[teamNo]!.indexWhere((loc)=>loc.userId == marker.userId);
    if(index!=-1){
      _teamLocations[teamNo]![index] = marker;
    }else{
      _teamLocations[teamNo]!.add(marker);
    }
    print(_teamLocations.toString());
    notifyListeners();
  }

  void stopTracking() {
    _positionStream.cancel();
    _currentPosition = null;
    _currentUserId = '';
    _isInitialized = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionStream.cancel();
    _locationUpdateTimer?.cancel();
    _locationStreamController.close();
    super.dispose();
  }
}