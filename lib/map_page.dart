import 'package:flutter/material.dart';
import 'package:test2/googlemap_image.dart';
import 'package:test2/googlemap_location.dart';
import 'package:test2/model/locationMarker.dart';

class MapPage extends StatefulWidget {
  final String userId;
  final String userName;
  const MapPage({super.key, required this.userId, required this.userName});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  String _selectedMapType = '팀원의 위치';
  final LocationManager _locationManager = LocationManager();

  @override
  void initState() {
    super.initState();
    _locationManager.initialize(widget.userId, widget.userName);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _selectedMapType == '팀원의 위치' ? GoogleMapLocation(userId: widget.userId, userName: widget.userName) : GoogleMapCluster(),
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
              items: ['팀원의 위치', '앨범']
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
