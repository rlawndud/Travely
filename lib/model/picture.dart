import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:test2/model/memberImg.dart';

class Picture{
  // int? pic_id;
  // String pic_title;
  // String pic_location;
  // DateTime pic_date;
  // String user_id;
  // //팀번호도 여기 잇으면 좋을듯
  // XFile pic;
  int? img_num;
  String user_id;
  String img_data;

  // Picture(this.pic_id, this.pic_title, this.pic_location, this.pic_date, this.user_id, this.pic);
  Picture(this.img_num, this.user_id, this.img_data);
  factory Picture.fromJson(Map<String, dynamic> json) {
    //String > XFile으로 변환하는 코드 추가하기

    return Picture(
      // json['pic_id'] as int?,
      // json['pic_title'] as String,
      // json['pic_location'] as String,
      // json['pic_date'] as DateTime,
      // json['user_id'] as String,
      // json['pic'] as XFile,
      json['img_num'] as int?,
      json['id'] as String,
      json['img_data'] as String,
    );
  }

  // Member 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    //XFile > String으로 변환하는 코드 추가하기
    return {
      // 'pic_id': pic_id,
      // 'pic_title': pic_title,
      // 'pic_location': pic_location,
      // 'pic_date': pic_date,
      // 'user_id': user_id,
      // 'pic': pic,
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