import 'package:image_picker/image_picker.dart';

class Picture{
  int? pic_id;
  String pic_title;
  String pic_location;
  DateTime pic_date;
  String user_id;
  //팀번호도 여기 잇으면 좋을듯
  XFile pic;

  Picture(this.pic_id, this.pic_title, this.pic_location, this.pic_date, this.user_id, this.pic);

  factory Picture.fromJson(Map<String, dynamic> json) {
    //String > XFile으로 변환하는 코드 추가하기

    return Picture(
      json['id'] as int?,
      json['pw'] as String,
      json['name'] as String,
      json['phone'] as DateTime,
      json['phone'] as String,
      json['phone'] as XFile,
    );
  }

  // Member 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    //XFile > String으로 변환하는 코드 추가하기

    return {
      'id': pic_id,
      'pw': pic_title,
      'name': pic_location,
      'phone': pic_date,
      'phone': user_id,
      'phone': pic,
    };
  }
}