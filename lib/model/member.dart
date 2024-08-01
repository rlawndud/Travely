class Member {
  String id;
  String password;
  String name;
  String phone;

  Member(this.id, this.password, this.name, this.phone);

  // JSON에서 Member 객체를 생성하는 팩토리 메서드
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      json['id'] as String,
      json['pw'] as String,
      json['name'] as String,
      json['phone'] as String,
    );
  }

  // Member 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pw': password,
      'name': name,
      'phone': phone,
    };
  }
  @override
  String toString() {
    // TODO: implement toString
    return "id: $id, pw: $password, name: $name, phone: $phone ";
  }
}
