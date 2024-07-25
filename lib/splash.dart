import 'dart:math';

import 'package:flutter/material.dart';
import 'package:test2/model/userLoginState.dart';
import 'package:test2/util/auto_login.dart';
import 'package:test2/network/web_socket.dart';

import 'model/member.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();

}

class _SplashState extends State<Splash> {
  final WebSocketService _webSocketService = WebSocketService();
  String? Id, Pw;

  @override
  void initState(){
    super.initState();
    _webSocketService.init();
    _navigateToLogin();
  }
  _navigateToLogin() async {
    await Future.delayed(Duration(milliseconds: 3000), () {});
    //만약 로그인 정보가 있으면 로그인 정보를 서버로 전달 후 바로 홈 화면으로 이동
    //await _checkLogin();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<bool> _checkLoginData() async {
    AutoLogin autoLogin = new AutoLogin();
    var loginInfo = await autoLogin.getLoginInfo();
    if(loginInfo[0]==null&&loginInfo[0]!.isEmpty){
      //로그인 데이터 x
      return false;
    }else{
      //로그인 데이터 o
      Id = loginInfo[0];
      Pw = loginInfo[1];
      return true;
    }
  }

  Future<void> _checkLogin() async {
    if(await _checkLoginData()){
      //서버로 아이디 비밀번호 전달 후 회원정보 획득
      var userDTO = new UserLoginState(Id!, Pw!);
      var response = _webSocketService.transmit(userDTO.toJson(),'login');
      Member.fromJson(response);
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
