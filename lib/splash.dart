import 'package:flutter/material.dart';
import 'package:test2/model/userLoginState.dart';
import 'package:test2/util/auto_login.dart';
import 'package:test2/network/web_socket.dart';

import 'home.dart';
import 'model/member.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final WebSocketService _webSocketService = WebSocketService();
  bool _isAuth = false;
  String? Id, Pw;

  @override
  void initState(){
    super.initState();
    _webSocketService.init();
    _navigateToLogin();
  }

  @override
  void didChangeDependencies() async{
    //sharedPreference에 저장된 토큰이 있는지 확인
    final loginInfo = await AutoLogin().getLoginInfo();
    if(loginInfo[0].isNotEmpty && loginInfo[1].isNotEmpty){
      _isAuth = true;
      Id = loginInfo[0];
      Pw = loginInfo[1];
    }
    super.didChangeDependencies();
  }
  _navigateToLogin() async {
    await Future.delayed(Duration(milliseconds: 3000), () {});
    //만약 로그인 정보가 있으면 로그인 정보를 서버로 전달 후 바로 홈 화면으로 이동
    await _checkLogin();
  }

  Future<void> _checkLogin() async {
    if(_isAuth){
      //서버로 아이디 비밀번호 전달 후 회원정보 획득
      var userDTO = new UserLoginState(Id!, Pw!);
      debugPrint('$Id,$Pw');
      var response = await _webSocketService.transmit(userDTO.toJson(),'login');
      debugPrint(response.toString());
      Member mem = Member.fromJson(response);
      //Member mem = new Member('id', 'password', 'name', 'phone');
      //홈화면으로 이동
      Navigator.pushReplacementNamed(context, '/home', arguments: {'user':mem});
    }else{
      Navigator.pushReplacementNamed(context, '/login');
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
