import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test2/network/web_socket.dart';

class EditInfoPage extends StatefulWidget {
  @override
  _EditInfoPageState createState() => _EditInfoPageState();
}

class _EditInfoPageState extends State<EditInfoPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _currentPasswordFocus = FocusNode();
  final FocusNode _newPasswordFocus = FocusNode();

  String currentPhoneNumber = '010-1234-5678';
  String email = 'user@example.com';
  String userId = 'user123';
  String profileImageUrl = 'https://via.placeholder.com/150';

  bool isCurrentPasswordValid = false;
  bool isPhoneVerified = false;

  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  final WebSocketService _webSocketService = WebSocketService();

  @override
  void initState() {
    super.initState();
    _webSocketService.init();
    _phoneController.addListener(_updatePhoneVerifyButton);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_updatePhoneVerifyButton);
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    super.dispose();
  }

  void _updatePhoneVerifyButton() {
    setState(() {
      // 상태 갱신을 트리거하여 버튼 상태를 업데이트합니다.
    });
  }

  Future<void> _updateProfile() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('새 비밀번호가 일치하지 않습니다.')),
      );
      return;
    }

    if (_newPasswordController.text.isNotEmpty && !_isPasswordValid(_newPasswordController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호는 8자 이상이어야 하며, 대소문자, 숫자, 특수문자를 포함해야 합니다.')),
      );
      return;
    }

    final profileData = {
      if (_phoneController.text.isNotEmpty && isPhoneVerified) 'phoneNumber': _phoneController.text,
      if (_newPasswordController.text.isNotEmpty) 'newPassword': _newPasswordController.text,
    };

    try {
      Uint8List imageBytes = _image != null ? await _image!.readAsBytes() : Uint8List(0);

      final response = await _webSocketService.updateProfile(profileData, imageBytes);
      if (response.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로필 업데이트 실패: ${response['error']}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 성공적으로 업데이트되었습니다!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류: ${e.toString()}')),
      );
    }
  }

  bool _isPasswordValid(String password) {
    final passwordRegExp = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegExp.hasMatch(password);
  }

  Future<void> _validateCurrentPassword(String value) async {
    // 임시 로직: 비밀번호가 '1234'인 경우 유효하다고 가정
    setState(() {
      isCurrentPasswordValid = (value == '1234');
    });
    if (isCurrentPasswordValid) {
      _newPasswordFocus.requestFocus();
    }

    // 실제 서버 연동 시 사용할 코드:
    /*
    try {
      final response = await _webSocketService.validatePassword({'password': value});
      setState(() {
        isCurrentPasswordValid = response['isValid'] ?? false;
      });
      if (isCurrentPasswordValid) {
        _newPasswordFocus.requestFocus();
      }
    } catch (e) {
      print('비밀번호 확인 중 오류 발생: $e');
      setState(() {
        isCurrentPasswordValid = false;
      });
    }
    */
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
        profileImageUrl = _image!.path;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _image = null;
      profileImageUrl = 'https://via.placeholder.com/150';
    });
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('이미지 업로드'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('이미지 삭제'),
                onTap: () {
                  Navigator.pop(context);
                  _removeImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _verifyPhoneNumber() async {
    // 실제 전화번호 인증 로직을 여기에 구현해야 합니다.
    setState(() {
      isPhoneVerified = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('전화번호가 인증되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('정보 수정'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _showImageOptions,
                      child: CircleAvatar(
                        backgroundImage: _image == null
                            ? NetworkImage(profileImageUrl)
                            : FileImage(File(_image!.path)) as ImageProvider,
                        radius: 40,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('사용자 ID: $userId', style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 5),
                    Text('Email: $email', style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 5),
                    Text('현재 전화번호: $currentPhoneNumber', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: '새 전화번호 입력 (선택사항)',
                  suffixIcon: isPhoneVerified
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : null,
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _phoneController.text.isNotEmpty && !isPhoneVerified
                    ? _verifyPhoneNumber
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueGrey,
                ),
                child: Text(isPhoneVerified ? '인증 완료' : '전화번호 인증하기'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _currentPasswordController,
                focusNode: _currentPasswordFocus,
                decoration: InputDecoration(
                  labelText: '현재 비밀번호 입력',
                  suffixIcon: isCurrentPasswordValid
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : null,
                ),
                obscureText: true,
                onSubmitted: (value) => _validateCurrentPassword(value),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _newPasswordController,
                focusNode: _newPasswordFocus,
                decoration: const InputDecoration(
                  labelText: '새 비밀번호 입력',
                  helperText: '8자 이상, 대소문자, 숫자, 특수문자 포함',
                ),
                obscureText: true,
                enabled: isCurrentPasswordValid,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: '새 비밀번호 다시 입력',
                ),
                obscureText: true,
                enabled: isCurrentPasswordValid,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blueGrey,
                      ),
                      child: const Text('수정'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('취소'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}