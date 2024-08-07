import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:test2/model/memberImg.dart';
import 'package:test2/network/web_socket.dart';

import 'model/picture.dart';
import 'model/team.dart';


class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  final WebSocketService _webSocketService = WebSocketService();
  int _selectedCameraIdx = 0;
  FlashMode _currentFlashMode = FlashMode.off;
  static XFile? _lastCapturedImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras![_selectedCameraIdx],
      ResolutionPreset.ultraHigh,
      enableAudio: false,
    );
    await _controller!.initialize();
    await _controller!.setFlashMode(_currentFlashMode);
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> uploadImage(XFile image) async {
    try{
      var images_string = XFileToBytes(image);
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('permissions are denied');
        }
      }
      Position position = await Geolocator.getCurrentPosition();
      String formatDate = DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now());
      Map<String, dynamic> data = {
        'id': PicManager().getCurrentId(),
        'teamno': TeamManager().getTeamNoByTeamName(TeamManager().currentTeam),
        'image': images_string,
        'location': position,
        'date': formatDate,
      };
      print('location: ${data['location']}, date: ${data['date']}');
      var response = await _webSocketService.transmit(data, 'AddImage');
      if(response['result']=='True'){
        setState(() {
          _lastCapturedImage = image;
        });
      }
    }catch(e){
      e.printError;
    }
  }

  void _toggleCameraLens() {
    if (_cameras!.length > 1) {
      setState(() {
        _selectedCameraIdx = (_selectedCameraIdx + 1) % _cameras!.length;
        _initializeCamera();
      });
    }
  }

  void _toggleFlashMode() {
    setState(() {
      switch (_currentFlashMode) {
        case FlashMode.off:
          _currentFlashMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          _currentFlashMode = FlashMode.always;
          break;
        case FlashMode.always:
          _currentFlashMode = FlashMode.off;
          break;
        case FlashMode.torch:
          break;
      }
    });
    _controller!.setFlashMode(_currentFlashMode);
  }

  IconData _getFlashIcon() {
    switch (_currentFlashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.torch:
        return Icons.highlight;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 화면의 크기를 구합니다.
    final size = MediaQuery.of(context).size;
    // 카메라 프리뷰의 크기를 계산합니다.
    var scale = size.aspectRatio * _controller!.value.aspectRatio;

    // 카메라가 화면보다 길 경우, scale을 조정합니다.
    if (scale < 1) scale = 1 / scale;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          // 카메라 프리뷰
          Transform.scale(
            scale: scale,
            child: Center(
              child: CameraPreview(_controller!),
            ),
          ),
          // 상단 컨트롤 영역
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: IconButton(
                      icon: Icon(_getFlashIcon(), color: Colors.white),
                      onPressed: _toggleFlashMode,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.cameraswitch, color: Colors.white),
                      onPressed: _toggleCameraLens,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 하단 컨트롤 영역
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              color: Colors.black54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ThumbnailWidget(image: _lastCapturedImage),
                  CustomCameraButton(
                    onPressed: () async {
                      try {
                        final image = await _controller!.takePicture();
                        await uploadImage(image);
                      } catch (e) {
                        print('Error taking picture: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to take picture: $e')),
                        );
                      }
                    },
                  ),
                  Container(width: 60, height: 60), // 균형을 위한 빈 컨테이너
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomCameraButton extends StatefulWidget {
  final VoidCallback onPressed;

  CustomCameraButton({required this.onPressed});

  @override
  _CustomCameraButtonState createState() => _CustomCameraButtonState();
}

class _CustomCameraButtonState extends State<CustomCameraButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Icon(
        _isPressed ? Icons.circle_outlined : Icons.circle,
        color: Colors.white,
        size: 80,
      ),
    );
  }
}

class ThumbnailWidget extends StatelessWidget {
  final XFile? image;

  const ThumbnailWidget({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(10),
        color: image!=null?null:Colors.black38,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: image != null
            ? Image.file(
          File(image!.path),
          fit: BoxFit.cover,
        )
            : Container(),
      ),
    );
  }
}