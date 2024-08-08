import 'package:flutter/material.dart';

class AddFriendPage extends StatelessWidget {
  final String currentUserName;
  final String currentUserId;
  final Function(String, String) addFriendRequest; // 파라미터 추가

  const AddFriendPage({
    super.key,
    required this.currentUserName,
    required this.currentUserId,
    required this.addFriendRequest, // 생성자에서 필수 파라미터로 선언
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController friendNameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friend'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: friendNameController,
              decoration: InputDecoration(
                labelText: 'Friend Name',
                labelStyle: TextStyle(color: Colors.blueAccent), // 추가
                border: OutlineInputBorder(), // 추가
              ),
              style: TextStyle(color: Colors.black), // 추가
            ),
            SizedBox(height: 16), // 추가
            ElevatedButton(
              onPressed: () {
                final String friendName = friendNameController.text;
                if (friendName.isNotEmpty) {
                  addFriendRequest(currentUserId, friendName);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add Friend'),
            ),
          ],
        ),
      ),
    );
  }
}