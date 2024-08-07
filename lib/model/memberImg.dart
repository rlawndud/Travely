import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class MemberImg {
  String id;
  String name;
  String img;

  MemberImg(this.id, this.name, this.img);

  factory MemberImg.fromJson(Map<String, dynamic> json){
    return MemberImg(
      json['id'],
      json['name'],
      json['img'],
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'id': id,
      'name': name,
      'face': img,
    };
  }
}

String XFileToBytes(XFile image) {
  final bytes = File(image.path).readAsBytesSync(); //image 를 byte로 불러옴
  return base64Encode(bytes);
}

Uint8List BytesToImage(String imgStr) {
  final bytes = base64Decode(imgStr);
  // return MemoryImage(bytes);
  return bytes;
}
