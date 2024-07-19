class Member {
  int? idx;
  String id;
  String pw;
  String name;
  String phone;

  Member(this.idx,this.id, this.pw, this.name, this.phone);

  // JSON에서 Member 객체를 생성하는 팩토리 메서드
/*  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      json['idx'] != null ? int.parse(json['idx']) : null,
      json['name'],
      json['img'],
    );
  }

  // Member 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'idx': idx,
      'name': name,
      'img': img,
    };
  }
  @override
  String toString() {
    // TODO: implement toString
    return "idx: $idx, name: $name, img: $img";
  }*/
}
