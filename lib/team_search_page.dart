import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeamSearchPage extends StatefulWidget {
  @override
  _TeamSearchPageState createState() => _TeamSearchPageState();
}

class _TeamSearchPageState extends State<TeamSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> _searchResults = [];

  Future<void> _searchTeams() async {
    final String query = _searchController.text;

    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('검색어를 입력해주세요.')),
      );
      return;
    }

    final QuerySnapshot snapshot = await _firestore
        .collection('teams')
        .where('name', isEqualTo: query)
        .get();

    setState(() {
      _searchResults = snapshot.docs;
    });
  }

  Future<void> _requestJoinTeam(String teamId) async {
    final User? user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    try {
      await _firestore.collection('teams').doc(teamId).update({
        'joinRequests': FieldValue.arrayUnion([user.uid]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('가입 요청을 보냈습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('가입 요청에 실패했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('팀 검색'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(labelText: '팀 이름 검색'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _searchTeams,
              child: Text('검색'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final team = _searchResults[index];
                  return ListTile(
                    title: Text(team['name']),
                    trailing: ElevatedButton(
                      onPressed: () => _requestJoinTeam(team.id),
                      child: Text('가입 요청'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
