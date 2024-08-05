import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test2/model/memberImg.dart';
import 'package:test2/model/picture.dart';
import 'package:test2/network/web_socket.dart';
import 'package:test2/value/color.dart';

class album extends StatefulWidget {
  const album({super.key});

  @override
  State<album> createState() => _albumState();
}

class _albumState extends State<album> {
  WebSocketService _webSocketService = WebSocketService();
  List<Picture> images = [];
  List<Uint8List> pic = [];

  Future<void> _loadImage() async {
    try {
      var img = await _webSocketService.transmit({'id': 'rlawndud'}, 'GetAllImage');
      debugPrint('이미지 로드 응답 : $img');

      if (img != null && img['img_data'] != null) {
        setState(() {
          images.add(Picture.fromJson(img));
        });
      } else {
        debugPrint('이미지 로드 실패');
      }
    } catch (e) {
      debugPrint('이미지 로딩 에러 : $e');
    }
  }

  void _printImage() {
    if (images.isNotEmpty) {
      print('images의 개수:${images.length}');
      setState(() {
        for (var img in images) {
          print('$img');
          pic.add(BytesToImage(img.img_data));
        }
        print('pic의 개수:${pic.length}');
      });
    }
  }

  Future<void> _takePictureAndSend() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
        Uint8List imgBytes = await photo.readAsBytes();
        debugPrint('이미지를 바이트로 읽음');
        var response = await _webSocketService.transmit({'image': imgBytes}, 'SendImage');
        debugPrint('서버 응답 : $response');

        if (response != null && response['success'] == true) {
          // 서버로부터 이미지를 받았다는 가정하에 처리
          setState(() {
            images.add(Picture.fromJson(response));
            pic.add(BytesToImage(response['img_data']));
          });
        } else {
          debugPrint('서버로 전달 실패');
        }
      }
    } catch (e) {
      debugPrint('서버로 사진을 보내는동안 오류가 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            width: 10,
            height: 50,
          ),
          TextButton(
            child: Text('이미지 불러오기'),
            onPressed: _loadImage,
            style: TextButton.styleFrom(
                backgroundColor: mainColor30, foregroundColor: Colors.white),
          ),
          TextButton(
            child: Text('이미지 출력하기'),
            onPressed: _printImage,
            style: TextButton.styleFrom(
                backgroundColor: mainColor30, foregroundColor: Colors.white),
          ),
          TextButton(
            child: Text('사진 촬영 및 전송'),
            onPressed: _takePictureAndSend,
            style: TextButton.styleFrom(
                backgroundColor: mainColor30, foregroundColor: Colors.white),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: pic.length,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                  height: 200,
                  child: Image.memory(pic[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// BytesToImage 함수가 정의되어 있는지 확인해야 합니다.
Uint8List BytesToImage(dynamic imgData) {
  // imgData를 Uint8List로 변환하는 로직이 필요합니다.
  // 예시:
  return Uint8List.fromList(List<int>.from(imgData));
}
