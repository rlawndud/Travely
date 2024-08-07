import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InviteUserPage extends StatefulWidget {
  final String teamId;

  const InviteUserPage({super.key, required this.teamId});

  @override
  _InviteUserPageState createState() => _InviteUserPageState();
}

class _InviteUserPageState extends State<InviteUserPage> {
  final TextEditingController _userIdController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _inviteUser() async {
    final String userId = _userIdController.text;

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용자 ID를 입력해주세요.')),
      );
      return;
    }

    try {
      await _firestore.collection('teams').doc(widget.teamId).update({
        'invitations': FieldValue.arrayUnion([userId]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용자를 초대했습니다.')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용자 초대에 실패했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('사용자 초대'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(labelText: '사용자 ID'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _inviteUser,
              child: Text('초대'),
            ),
          ],
        ),
      ),
    );
  }
}