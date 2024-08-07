class UserLoginState{
  String id;
  String password;

  UserLoginState(this.id, this.password);

  String getId(){
    return id;
  }
  void setId(String id){
    this.id = id;
  }
  String getPassword(){
    return password;
  }
  void setPassword(String password){
    this.password = password;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pw': password,
    };
  }
}