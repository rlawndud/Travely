import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:test2/network/web_socket.dart';
import 'package:test2/util/auto_login.dart';
import 'package:test2/value/color.dart';

import 'model/member.dart';
import 'model/team.dart';
import 'model/userLoginState.dart';

class Login extends StatelessWidget {
  final RxBool _isAutoLogin = false.obs;

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  void _login(BuildContext context) async {

    String id = _idController.text.toString();
    String pw = _pwController.text.toString();

    //SharedPreferences에 로그인 정보 저장
    AutoLogin autoLogin = new AutoLogin();

    //// 서버에 로그인 정보 전달 및 회원정보 획득
    // UserLoginState loginInfo = new UserLoginState(_idController.text, _pwController.text);
    // WebSocketService _webSocketService = WebSocketService();
    // try{
    //   //처리 정상
    //   var response = await _webSocketService.transmit(loginInfo.toJson(), 'Login');
    //   debugPrint(response.toString());
    //   if (response['result'] == 'False') {
    //     Fluttertoast.showToast(
    //       msg: '등록되지 않은 아이디이거나\n잘못된 비밀번호를 입력하였습니다.',
    //       gravity: ToastGravity.BOTTOM,
    //       backgroundColor: Colors.white70,
    //       textColor: Colors.black,
    //       toastLength: Toast.LENGTH_LONG,
    //     );
    //   } else {
    //     Member mem = Member.fromJson(response);
    //     //Member mem = new Member('id', 'password', 'name', 'phone');
    //     autoLogin.setLoginInfo(_isAutoLogin, new UserLoginState(id, pw));
    //     await TeamManager().initialize(mem.id);
    //     Navigator.pushReplacementNamed(context, '/home',
    //         arguments: {'user': mem});
    //   }
    // } catch (e) {
    //   Fluttertoast.showToast(
    //       msg: '로그인 중 오류가 발생했습니다',
    //       gravity: ToastGravity.BOTTOM,
    //       backgroundColor: Colors.white70,
    //       textColor: Colors.black,
    //       toastLength: Toast.LENGTH_LONG);
    //   e.printError();
    // }

    // 로그인 없이 바로 들어가기 => 로그인 살리고 싶으면 아래 주석 처리 후 위 코드 주석 해제
    Member mem = new Member('id', 'password', 'name', 'phone');
    autoLogin.setLoginInfo(_isAutoLogin, new UserLoginState(id, pw));
    await TeamManager().initialize(mem.id);
    Navigator.pushReplacementNamed(context, '/home',
        arguments: {'user': mem});
  }

  void _signup(BuildContext context) {
    Navigator.pushNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/login_background.png',
                fit: BoxFit.cover,
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: TextField(
                          controller: _idController,
                          decoration: InputDecoration(
                            hintText: 'ID',
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: mainColor,
                              ),
                            ),
                          ),
                          cursorColor: mainColor,
                        ),
                        padding: EdgeInsets.fromLTRB(82.0, 90.0, 82.0, 0.0),
                      ),
                      SizedBox(height: 30),
                      Container(
                        child: TextField(
                          controller: _pwController,
                          decoration: InputDecoration(
                            hintText: 'PW',
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: mainColor,
                              ),
                            ),
                          ),
                          cursorColor: mainColor,
                          obscureText: true,
                        ),
                        padding: EdgeInsets.fromLTRB(82.0, 0.0, 82.0, 0.0),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Obx(() {
                            return Checkbox(
                                materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                                activeColor: mainColor,
                                checkColor: Colors.white,
                                side: BorderSide(
                                  color: Color.fromARGB(195, 58, 58, 58),
                                ),
                                value: _isAutoLogin.value,
                                onChanged: (bool? value) {
                                  _isAutoLogin.value = value!;
                                });
                          }),
                          Text(
                            '자동 로그인',
                            style: TextStyle(
                              color: Color.fromARGB(195, 58, 58, 58),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => _login(context),
                            child: Text('로그인'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(110, 35),
                              backgroundColor: mainColor,
                              foregroundColor: Colors.white,
                              shadowColor: mainColor,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10), // 버튼의 모서리 둥글기
                              ),
                            ),
                          ),
                          SizedBox(width: 30),
                          ElevatedButton(
                            onPressed: () => _signup(context),
                            child: Text(
                              '회원가입',
                              style: TextStyle(
                                color: mainColor,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(110, 35),
                              overlayColor: mainColor30,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10), // 버튼의 모서리 둥글기
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
