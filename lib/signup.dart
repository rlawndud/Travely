import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:test2/home.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String _errorMsg = "";

  @override
  void initState() {
    super.initState();
  }
  void checkId(String input_id){
    //중복 검사
    //서버로 입력받은 아이디를 보내 해당 아이디가 이미 존재하는 지 확인
    if(_formKey.currentState!.validate()){
      _formKey.currentState!.save();
    }
  }
  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _signup() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      //회원객체를 만들어서 서버로 전송하는 코드 추가
      print('아이디 : '+_idController.text);
      print('비밀번호: '+_pwController.text);
      print('이름: '+_nameController.text);
      print('전화번호: '+_phoneController.text);

      //얼굴사진 찍고 표시할까말까
      Navigator.pop(context);
    }
  }

  void takePic(){

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/login_background.png',
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(100.0,160.0,100.0,80.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'ID',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '아이디를 입력하세요';
                      }
                      else if(value=='abc'){

                      }
                      return null;
                    },
                    controller: _idController,
                    onChanged: (text){
                      checkId(text);
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'PW',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력하세요';
                      }
                      else if(_errorMsg!=''){
                        return _errorMsg;
                      }
                      return null;
                    },
                    controller: _pwController,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Name',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이름을 입력하세요';
                      }
                      return null;
                    },
                    controller: _nameController,
                  ),
                  SizedBox(height: 50),
                  // TextFormField(
                  //   decoration: InputDecoration(
                  //     hintText: '전화번호',
                  //     filled: true,
                  //     fillColor: Colors.white,
                  //   ),
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return '전화번호를 입력하세요';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  // SizedBox(height: 20),
                  Column(
                    //사용자 사진(5장)등록 버튼
                    children: [
                      ElevatedButton(
                        onPressed: takePic,
                        child: Text('사진등록',
                          // style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          // backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                            // overlayColor: Colors.white
                        ),
                      ),
                      Text('해당 사진은 어플의 얼굴분석에 사용되며,\n 상업적으로 이용되지 않습니다.',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _signup,
                    child: Text('회원가입'),
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      // overlayColor: Colors.white
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
