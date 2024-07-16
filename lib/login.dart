import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login(BuildContext context) {
    //검사
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _signup(BuildContext context) {
    Navigator.pushNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  /*TextField(
                    controller: _idController,
                    decoration: InputDecoration(
                      labelText: '아이디',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),*/
                  Container(
                    child: TextField(
                      controller: _idController,
                      decoration: InputDecoration(
                        hintText: 'ID',
                        filled: true,
                        fillColor: Colors.white,

                      ),
                    ),
                    width: 180,
                  ),
                  SizedBox(height: 50),
                  Container(
                    child: TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: 'PW',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      obscureText: true,
                    ),
                    width: 180,
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
                          backgroundColor: Colors.deepPurpleAccent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.deepPurpleAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15), // 버튼의 모서리 둥글기
                          ),
                        ),
                      ),
                      SizedBox(width: 40),
                      ElevatedButton(
                        onPressed: () => _signup(context),
                        child: Text('회원가입'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(70, 30),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurpleAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // 버튼의 모서리 둥글기
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
    );
  }
}
