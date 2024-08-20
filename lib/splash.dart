import 'package:flutter/material.dart';
import 'package:travley/model/team.dart';
import 'package:travley/model/userLoginState.dart';
import 'package:travley/util/auto_login.dart';
import 'package:travley/network/web_socket.dart';
import 'package:travley/model/member.dart';

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
    debugPrint(_isAuth.toString());
    super.didChangeDependencies();
  }
  _navigateToLogin() async {
    await Future.delayed(Duration(milliseconds: 3000), () {});
    //만약 로그인 정보가 있으면 로그인 정보를 서버로 전달 후 바로 홈 화면으로 이동
    await _checkLogin();
  }

  Future<void> _checkLogin() async {
    try{
      if(_isAuth){
        //서버로 아이디 비밀번호 전달 후 회원정보 획득
        var userDTO = new UserLoginState(Id!, Pw!);
        debugPrint('$Id,$Pw');
        var response = await _webSocketService.transmit(userDTO.toJson(),'Login');
        debugPrint(response.toString());
        Member mem = Member.fromJson(response);
        await TeamManager().initialize(mem.id);
        //홈화면으로 이동
        Navigator.pushReplacementNamed(context, '/home', arguments: {'user':mem});
      }else{
        Navigator.pushReplacementNamed(context, '/login');
      }
    }catch(e){
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
