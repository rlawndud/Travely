import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeamCreationPage extends StatefulWidget {
  @override
  _TeamCreationPageState createState() => _TeamCreationPageState();
}

class _TeamCreationPageState extends State<TeamCreationPage> {
  final TextEditingController _teamNameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _createTeam() async {
    final String teamName = _teamNameController.text;

    if (teamName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('팀 이름을 입력해주세요.')),
      );
      return;
    }

    final User? user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    try {
      await _firestore.collection('teams').add({
        'name': teamName,
        'creatorId': user.uid,
        'members': [user.uid],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('팀이 생성되었습니다.')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('팀 생성에 실패했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('팀 생성'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _teamNameController,
              decoration: InputDecoration(labelText: '팀 이름'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _createTeam,
              child: Text('팀 생성'),
            ),
          ],
        ),
      ),
    );
  }
}
