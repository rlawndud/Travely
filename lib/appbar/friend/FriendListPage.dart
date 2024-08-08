import 'package:flutter/material.dart';
import 'FriendRequestModel.dart';

class FriendListPage extends StatelessWidget {
  final List<FriendRequest> acceptedFriends;

  const FriendListPage({super.key, required this.acceptedFriends});

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 목록'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: acceptedFriends.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(acceptedFriends[index].senderName),
          );
        },
      ),
    );
  }
}