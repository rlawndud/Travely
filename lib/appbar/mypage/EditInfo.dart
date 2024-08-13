import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../model/member.dart';

class EditInfoPage extends StatefulWidget {
  final Member user;
  const EditInfoPage({super.key, required this.user});

  @override
  _EditInfoPageState createState() => _EditInfoPageState();
}

class _EditInfoPageState extends State<EditInfoPage> {
  late Member _user;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String profileImageUrl = 'https://via.placeholder.com/150';

  bool isCurrentPasswordValid = false;

  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  void _updateInfo() {
    final String newPhoneNumber = _phoneController.text;
    final String newPassword = _newPasswordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('새 비밀번호가 일치하지 않습니다')),
      );
      return;
    }

    // 여기에 비밀번호 및 전화번호 업데이트 로직을 추가할 수 있습니다.
    // 예: 서버에 업데이트 요청 보내기

    // 정보 수정 성공 메시지
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('정보 수정되었습니다')),
    );

    // 업데이트가 완료되면 이전 화면으로 돌아가기
    Navigator.pop(context);
  }

  void _validateCurrentPassword(String value) {
    setState(() {
      isCurrentPasswordValid = value == _user.password;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
        profileImageUrl = _image!.path;
      });
      // 여기에 서버에 이미지를 업로드하는 로직을 추가할 수 있습니다.
      // 업로드가 완료되면 서버에서 제공하는 URL을 profileImageUrl에 할당
    }
  }

  void _removeImage() {
    setState(() {
      _image = null;
      profileImageUrl = 'https://via.placeholder.com/150'; // 기본 이미지 URL로 변경
    });
    // 여기에 서버에서 이미지를 제거하는 로직을 추가할 수 있습니다.
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
                title: const Text('프로필 사진 변경'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('프로필 사진 삭제'),
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
                    Text('아이디: ${_user.id}', style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 5),
                    Text('이름: ${_user.name}', style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 5),
                    Text('현재 전화번호: ${_user.phone}', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: '새 전화번호',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  print('전화번호 확인: ${_phoneController.text}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // 버튼 배경 색상
                  foregroundColor: Colors.blueGrey, // 버튼 텍스트 색상
                ),
                child: const Text('전화번호 인증하기'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _currentPasswordController,
                decoration: const InputDecoration(
                  labelText: '현재 비밀번호',
                ),
                obscureText: true,
                onChanged: _validateCurrentPassword,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _newPasswordController,
                decoration: const InputDecoration(
                  labelText: '새 비밀번호',
                ),
                obscureText: true,
                enabled: isCurrentPasswordValid,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: '새 비밀번호 확인',
                ),
                obscureText: true,
                enabled: isCurrentPasswordValid,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _updateInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // 버튼 배경 색상
                        foregroundColor: Colors.blueGrey, // 버튼 텍스트 색상
                      ),
                      child: const Text('정보 수정'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey, // 버튼 배경 색상
                        foregroundColor: Colors.white, // 버튼 텍스트 색상
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