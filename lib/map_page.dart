import 'package:flutter/material.dart';
import 'package:travley/googlemap_image.dart';
import 'package:travley/googlemap_location.dart';

class MapPage extends StatefulWidget {
  final String userId;
  final String userName;
  const MapPage({super.key, required this.userId, required this.userName});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  String _selectedMapType = '팀원의 위치';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildMap(),
        _buildMapTypeSelector(),
      ],
    );
  }

  Widget _buildMap() {
    return _selectedMapType == '팀원의 위치'
        ? GoogleMapLocation(userId: widget.userId, userName: widget.userName)
        : GoogleMapCluster();
  }

  Widget _buildMapTypeSelector() {
    return Positioned(
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
          items: ['팀원의 위치', '지도 위 앨범']
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
    );
  }
}
