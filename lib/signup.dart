import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test2/network/web_socket.dart';
import 'package:test2/value/color.dart';

import 'model/member.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final WebSocketService _webSocketService = WebSocketService();
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool sendPic_enable = false;
  bool signUp_enable = false;
  bool? _isIdAvailable;

  String _errorMsg = "";

  @override
  void initState() {
    super.initState();
  }

  Future<void> checkId() async {
    //중복 검사
    //서버로 입력받은 아이디를 보내 해당 아이디가 이미 존재하는 지 확인
    Map<String, dynamic> data = {'id': _idController.text};
    print(data);

    var jsonResponse = await _webSocketService.transmit(data, 'IdDuplicate');
    print(jsonResponse);


    if(jsonResponse['result']=='False'){
     setState(() {
       _errorMsg = "이미 존재하는 아이디입니다.";
       _isIdAvailable = false;
     });
   }else{
     setState(() {
       _errorMsg = "사용할 수 있는 아이디입니다.";
       _isIdAvailable = true;
     });
   }
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String hintText,
    required String? Function(String?) validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: hintText == 'ID'
            ? _isIdAvailable != null
            ? _isIdAvailable == true
            ? Icon(Icons.check_circle, color: Colors.green)
            : Icon(Icons.error, color: Colors.red)
            : null
            : null,
      ),
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      obscureText: obscureText,
    );
  }

  void _signup() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      //회원객체를 만들어서 서버로 전송하는 코드 추가
      print('아이디 : ' + _idController.text);
      print('비밀번호: ' + _pwController.text);
      print('이름: ' + _nameController.text);
      print('전화번호: ' + _phoneController.text);

      Member newmem = new Member(_idController.text, _pwController.text, _nameController.text, _phoneController.text);

      _webSocketService.transmit(newmem.toJson(), 'AddMember');

      //얼굴사진 찍고 표시할까말까
      Navigator.pop(context);
    }
  }

  void takePic() {}
  final FocusNode _focusNode = FocusNode();
  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      debugPrint('##### focus on #####');
    } else {
      debugPrint('##### focus off #####');
      checkId();
    }
  }

  @override
  Widget build(BuildContext context) {
    //포커스 상태 확인을 위한 리스너
    _focusNode.addListener(_handleFocusChange);
    return GestureDetector(
      onTap: ()=>FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            foregroundColor: Colors.white,
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/background.png',
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(98.0, 60.0, 98.0, 0.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _buildTextFormField(
                        controller: _idController,
                        focusNode: _focusNode,
                        hintText: 'ID',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '아이디를 입력하세요';
                          } else if (_errorMsg.isNotEmpty) {
                            return _errorMsg;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      _buildTextFormField(
                        controller: _pwController,
                        hintText: 'PW',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '비밀번호를 입력하세요';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      _buildTextFormField(
                        controller: _nameController,
                        hintText: 'Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이름을 입력하세요';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      _buildTextFormField(
                        controller: _phoneController,
                        hintText: 'Phone',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '전화번호를 입력하세요';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 40),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: sendPic_enable ? takePic : null,
                            child: Text('사진등록', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mainColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          Text(
                            '해당 사진은 어플의 얼굴분석에 사용되며,\n 상업적으로 이용되지 않습니다.',
                            style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _signup,
                        child: Text('회원가입'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
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
