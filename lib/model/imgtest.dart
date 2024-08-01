import 'dart:convert';
import 'dart:io';
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
      var img =
      await _webSocketService.transmit({'id': 'rlawndud'}, 'GetAllImage');

      debugPrint(img.toString());
      images.add(Picture.fromJson(img));
    } catch (e) {
      e.printError();
    }
  }

  void _printImage() {
    if (images.isNotEmpty) {
      print('images의 개수:${images.length}');
      for (var img in images) {
        print('$img');
        pic.add(BytesToImage(img.img_data));

        print('pic의 개수:${pic.length}');
        setState(() {});
      }
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
          Expanded(
            child: ListView.builder(
              itemCount: pic.length,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                  height: 200,
                  child: Image.memory(pic[0]),
                );
              },
            ),
          ),
          /*Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: FileImage(File(images[index]!.path)),
              ),
            ),
          ),*/
        ],
      ),
    );
  }
}
