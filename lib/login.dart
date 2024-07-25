import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test2/network/web_socket.dart';
import 'package:test2/util/auto_login.dart';
import 'package:test2/value/color.dart';

import 'model/userLoginState.dart';

class Login extends StatelessWidget {
  final RxBool _isAutoLogin = false.obs;

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  void _login(BuildContext context) async {
    //SharedPreferences에 로그인 정보 저장
    AutoLogin autoLogin = new AutoLogin();
    autoLogin.setLoginInfo(
        _isAutoLogin, _idController.text, _pwController.text);
    //서버에 로그인 정보 전달 및 회원정보 획득
    UserLoginState loginInfo =
        new UserLoginState(_idController.text, _pwController.text);
    WebSocketService _webSocketService = WebSocketService();
    _webSocketService.transmit(loginInfo.toJson(), 'Login');

    Navigator.pushNamed(context, '/home');
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
                'assets/background.png',
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
                        padding: EdgeInsets.fromLTRB(82.0, 0.0, 82.0, 0.0),
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
