import 'package:flutter/material.dart';
import 'package:test2/model/auto_login.dart';
import 'package:test2/network/web_socket.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState(){
    super.initState();
    _navigateToLogin();
  }
  _navigateToLogin() async {
    await Future.delayed(Duration(milliseconds: 3000), () {});
    //만약 로그인 정보가 있으면 로그인 정보를 서버로 전달 후 바로 홈 화면으로 이동
    Navigator.pushReplacementNamed(context, '/login');
  }

  bool _checkLoginData(){
    AutoLogin autoLogin = new AutoLogin();
    String? Id = autoLogin.getLoginInfo()[0];
    String? Pw = autoLogin.getLoginInfo()[1];
    if(Id!.isEmpty && Pw!.isEmpty){
      //로그인 데이터 x
      return false;
    }else{
      //로그인 데이터 o
      return true;
    }
  }

  void _checkLogin(){
    if(_checkLoginData()){
      //서버로 아이디 비밀번호 전달 후 회원정보 획득
      //홈화면으로 이동
      //내일 오면 이거하기!!
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/loading_image.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
