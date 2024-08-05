import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:test2/model/memberImg.dart';

class Picture{
  int? img_num;
  String user_id;
  String img_data;
  Picture(this.img_num, this.user_id, this.img_data);
  factory Picture.fromJson(Map<String, dynamic> json) {
    //String > XFile으로 변환하는 코드 추가하기

    return Picture(
      json['img_num'] as int?,
      json['id'] as String,
      json['img_data'] as String,
    );
  }

  // Member 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    //XFile > String으로 변환하는 코드 추가하기
    return {
      'img_num':img_num,
      'id': user_id,
      'img_data': img_data,
    };
  }
  @override
  String toString() {
    return 'img_num: $img_num, user_id: $user_id, img_data: ${img_data}';
  }
}

class PictureEntity{
  int img_num;
  String user_id;
  String img_data;
  int team_num;
  String pre_face;
  String pre_background;


  PictureEntity(this.img_num, this.user_id, this.img_data, this.team_num, this.pre_face, this.pre_background);

  factory PictureEntity.fromJson(Map<String, dynamic> json){
    return PictureEntity(
      json['img_num'] as int,
      json['id'] as String,
      json['img_data'] as String,
      json['teamno'] as int,
      json['pre_face'] as String,
      json['pre_background'] as String,
    );
  }

  @override
  String toString() {
    return ('사진 속 인물 : $pre_face\n 사진 배경 : $pre_background');
  }
}

class PicManager{

}