import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test2/model/memberImg.dart';
import 'package:test2/model/picture.dart';
import 'package:test2/model/team.dart';
import 'package:test2/network/web_socket.dart';
import 'package:test2/value/color.dart';

class album extends StatefulWidget {
  final String id;
  const album({super.key, required this.id});

  @override
  State<album> createState() => _albumState();
}

class _albumState extends State<album> {
  WebSocketService _webSocketService = WebSocketService();
  List<PictureEntity> images = [];
  List<Uint8List> pic = [];
  TeamManager teamManager = TeamManager();
  PicManager _picManager = PicManager();
  String currentTeamName = '';
  int? currentTeam;
  String prediction='';
  final TextEditingController predict = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentTeamName = TeamManager().currentTeam;
    currentTeam = teamManager.getTeamNoByTeamName(currentTeamName);
  }

  Future<void> _loadImage() async {
    try {
      Map<String,dynamic> response = await _webSocketService.transmit({'id': widget.id}, 'GetAllImage');
      debugPrint('이미지 로드 응답 : $response');

      if (response != null && response['img_data'] != null) {
        setState(() {
          PictureEntity p_pic = PictureEntity.fromJson(response);
          images.add(p_pic);
          prediction = p_pic.toString();
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
        var images_string = XFileToBytes(photo);
        debugPrint('이미지를 바이트로 읽음');
        Map<String, dynamic> data = {
          'id':widget.id,
          'teamno':currentTeam,
          'image': images_string,
        };
        print(data);
        var response = await _webSocketService.transmit(data, 'AddImage');
        PictureEntity pre_pic =  PictureEntity.fromJson(response);
        await _picManager.addPicture(pre_pic);
        prediction = pre_pic.printPredict();
        setState(() {
          pic.add(BytesToImage(pre_pic.img_data));
          print('pic의 개수:${pic.length}');
        });
        debugPrint('서버 응답 : $response');

        if (response != null && response['success'] == true) {
          // 서버로부터 이미지를 받았다는 가정하에 처리
          setState(() {
            images.add(PictureEntity.fromJson(response));
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
          SizedBox(height: 50,),
          TextButton(
            child: Text('사진 촬영 및 전송'),
            onPressed: _takePictureAndSend,
            style: TextButton.styleFrom(
                backgroundColor: mainColor30, foregroundColor: Colors.white),
          ),
          SizedBox(height: 10,),
          TextButton(
              onPressed: (){
                Map<String,dynamic> team = {
                  'teamNo':currentTeam,
                };
                _webSocketService.transmit(team, 'TravelStart');
                print(team);
              },
              style: TextButton.styleFrom(
                backgroundColor: mainColor, foregroundColor: Colors.white, padding: const EdgeInsets.all(15.0),shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(10), // 버튼의 모서리 둥글기
              ),),
              child: Text('여행 시작',style: TextStyle(fontSize: 18),)),
          Text('현재 팀 : $currentTeamName',style: TextStyle(fontSize: 20),),
          SizedBox(height: 10,),
          Text(
            prediction,
            style: TextStyle(fontSize: 15),
            textAlign: TextAlign.center,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: pic.length,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                  height: 300,
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
