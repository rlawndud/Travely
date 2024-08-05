import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test2/model/memberImg.dart';
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
  final FocusNode _focusNode = FocusNode();

  bool signUp_enable = false;
  bool? _isIdAvailable;

  String _errorMsg = "";

  final picker = ImagePicker();
  XFile? image;
  List<XFile?> images = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  Future<void> _checkId() async {
    //중복 검사
    //서버로 입력받은 아이디를 보내 해당 아이디가 이미 존재하는 지 확인
    Map<String, dynamic> data = {'id': _idController.text};

    var jsonResponse = await _webSocketService.transmit(data, 'IdDuplicate');
    print(jsonResponse);

    if (jsonResponse['result'] == 'True') {
      setState(() {
        _errorMsg = "이미 존재하는 아이디입니다.";
        _isIdAvailable = false;
      });
    } else if (jsonResponse['result'] == 'False') {
      setState(() {
        _errorMsg = "";
        _isIdAvailable = true;
      });
    } else if (jsonResponse.containsKey('error')) {
      debugPrint(jsonResponse['error']);
      _errorMsg = "";
      _isIdAvailable = false;
    }
    _updateSignUpEnable();
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

  void _updateSignUpEnable() {
    setState(() {
      signUp_enable = _formKey.currentState?.validate() == true &&
          _isIdAvailable == true &&
          images.length == 5;
    });
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
        suffixIcon: hintText == 'ID' && controller.text.isNotEmpty
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
      onChanged: (value) {
        _updateSignUpEnable();
      },
    );
  }

  void _showExplainToast() {
    Fluttertoast.showToast(
        msg: '다섯 장의 얼굴 사진을 찍어주세요.',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.white70,
        fontSize: 12,
        textColor: Colors.black,
        toastLength: Toast.LENGTH_SHORT);
  }

  void _signup() {
    _formKey.currentState!.save();
    //회원객체를 만들어서 서버로 전송하는 코드 추가
    print('아이디 : ' + _idController.text);
    print('비밀번호: ' + _pwController.text);
    print('이름: ' + _nameController.text);
    print('전화번호: ' + _phoneController.text);

    Member mem = new Member(_idController.text, _pwController.text,
        _nameController.text, _phoneController.text);
    var images_string = '';
    images.forEach((img) {
      images_string += XFileToBytes(img!) + '\$';
    });
    MemberImg memImg =
        new MemberImg(_idController.text, _nameController.text, images_string);
    try {
      _webSocketService.transmit(mem.toJson(), 'AddMember');
      _webSocketService.transmit(memImg.toJson(), 'AddMemImg');
      Fluttertoast.showToast(
          msg: '회원가입 성공!',
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.white70,
          fontSize: 12,
          textColor: Colors.black,
          toastLength: Toast.LENGTH_LONG);
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
          msg: '회원가입 중 오류가 발생했습니다',
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.white70,
          fontSize: 12,
          textColor: Colors.black,
          toastLength: Toast.LENGTH_LONG);
    }
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _checkId();
    }
  }

  @override
  Widget build(BuildContext context) {
    //포커스 상태 확인을 위한 리스너
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: mainColor, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
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
                padding: const EdgeInsets.fromLTRB(98.0, 90.0, 98.0, 0.0),
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
                            onPressed: () async {
                              while (images.length < 5) {
                                _showExplainToast();
                                var image = await picker.pickImage(
                                    source: ImageSource.camera);
                                // 카메라로 촬영하지 않고 뒤로가기 버튼을 누를 경우 null 값이 저장되므로
                                // if 문을 통해 null이 아닐 경우에만 images 변수로 저장하도록 합니다
                                if (image != null) {
                                  setState(() {
                                    images.add(image);
                                  });
                                }
                                _updateSignUpEnable();
                                print(images.length);
                              }
                            },
                            child: Text('사진추가',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mainColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          Text(
                            '해당 사진은 어플의 얼굴분석에 사용되며,\n 상업적으로 이용되지 않습니다.',
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      //찍은 사진들 화면에 출력
                      Container(
                        margin: EdgeInsets.all(10),
                        child: GridView.builder(
                          padding: EdgeInsets.all(0),
                          shrinkWrap: true,
                          itemCount: images.length,
                          //보여줄 item 개수. images 리스트 변수에 담겨있는 사진 수 만큼.
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, //1 개의 행에 보여줄 사진 개수
                            childAspectRatio: 1 / 1, //사진 의 가로 세로의 비율
                            mainAxisSpacing: 10, //수평 Padding
                            crossAxisSpacing: 10, //수직 Padding
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            // 사진 오른 쪽 위 삭제 버튼을 표시하기 위해 Stack을 사용함
                            return Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          //사진 크기를 Container 크기에 맞게 조절
                                          image: FileImage(File(images[index]!
                                                  .path // images 리스트 변수 안에 있는 사진들을 순서대로 표시함
                                              )))),
                                ),
                                Container(
                                    width: 20.0,
                                    height: 20.0,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    //삭제 버튼
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.black,
                                        size: 15,
                                      ),
                                      onPressed: () {
                                        //버튼을 누르면 해당 이미지가 삭제됨
                                        setState(() {
                                          images.remove(images[index]);
                                          _updateSignUpEnable();
                                        });
                                      },
                                    ))
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: signUp_enable ? _signup : null,
                        child: Text('회원가입',
                            style: TextStyle(
                              color: signUp_enable ? mainColor : Colors.white30,
                            )),
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
