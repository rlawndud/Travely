import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:test2/model/picture.dart';
import 'package:test2/util/auto_login.dart';
import 'package:test2/value/color.dart';
import 'package:test2/model/team.dart';
import 'model/member.dart';
import 'network/web_socket.dart';

class SettingsPage extends StatefulWidget {
  final Member user;

  const SettingsPage({super.key, required this.user});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Member _user;
  final WebSocketService _webSocketService = WebSocketService();
  final TextEditingController _pwController = TextEditingController();
  final RxBool _isAutoLogin = false.obs;
  bool _isPwCorrect = false;
  final FocusNode _focusNode = FocusNode();
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _validatePassword();
    }
  }

  void _validatePassword() {
    setState(() {
      _isPwCorrect = (_pwController.text == _user.password);
      _errorMsg = _isPwCorrect ? '' : '비밀번호가 일치하지 않습니다.';
    });
  }


  void _logout(BuildContext context) async {
    try {
      await _webSocketService.transmit({'id': _user.id}, 'Logout');
      AutoLogin autoLogin = new AutoLogin();
      autoLogin.setLoginState(_isAutoLogin);
      debugPrint(_isAutoLogin.toString());

      await TeamManager().clearCurrentUserData();
      await PicManager().clearCurrentUserData();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      Fluttertoast.showToast(
          msg: '로그아웃 중 오류가 발생했습니다: $e',
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.white70,
          fontSize: 12,
          textColor: Colors.black,
          toastLength: Toast.LENGTH_LONG);
    }
  }

  void _deleteMember() async {
    debugPrint(_isPwCorrect.toString());
    try {
      await _webSocketService.transmit({'id': _user.id}, 'DeleteMember');
      Navigator.of(context).pop();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      Fluttertoast.showToast(
          msg: '회원 탈퇴 중 오류가 발생했습니다: $e',
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.white70,
          fontSize: 12,
          textColor: Colors.black,
          toastLength: Toast.LENGTH_LONG);
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    _pwController.clear();
    _errorMsg = '';
    _isPwCorrect = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('회원 탈퇴'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('정말로 탈퇴하시겠습니까? 이 작업은 되돌릴 수 없습니다'),
              TextField(
                controller: _pwController,
                decoration: InputDecoration(
                  errorText: _errorMsg.isNotEmpty ? _errorMsg : null,
                ),
                focusNode: _focusNode,
              ),
              Text(
                '탈퇴하시려면 비밀번호를 입력해주세요',
                style: TextStyle(color: Colors.black87, fontSize: 11),
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                '취소',
                style: TextStyle(
                  color: mainColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                '탈퇴',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: mainColor,
              ),
              onPressed: _isPwCorrect ? _deleteMember : null,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('로그아웃'),
            trailing: Icon(Icons.navigate_next),
            onTap: () => _logout(context),
            //로그아웃 요청(현재 회원 아이디 전송)
          ),
          ListTile(
            leading: Icon(Icons.close),
            title: Text('회원 탈퇴'),
            trailing: Icon(Icons.navigate_next),
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }
}
