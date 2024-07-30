import 'package:flutter/material.dart';
import 'package:test2/AddFrindPage.dart'; // 오타 수정
import 'FriendRequestsPage.dart';
import 'FriendRequestModel.dart';

class Friend extends StatefulWidget {
  const Friend({super.key}); // const 생성자

  @override
  _FriendState createState() => _FriendState();
}

class _FriendState extends State<Friend> {
  List<FriendRequest> friendRequests = [];

  void _addFriendRequest(String senderId, String senderName) {
    setState(() {
      friendRequests.add(FriendRequest(senderId: senderId, senderName: senderName));
    });
  }

  void _acceptFriendRequest(FriendRequest request) {
    setState(() {
      friendRequests.remove(request);
    });
    print('Accepted friend request from: ${request.senderName}');
  }

  void _declineFriendRequest(FriendRequest request) {
    setState(() {
      friendRequests.remove(request);
    });
    print('Declined friend request from: ${request.senderName}');
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserName = 'John Doe'; // 적절한 사용자 이름을 입력
    final String currentUserId = 'user123'; // 적절한 사용자 ID를 입력

    return Scaffold(
      appBar: AppBar(
        title: const Text('𝑭𝒓𝒊𝒆𝒏𝒅'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_add_alt_sharp),
            title: const Text('친구 추가'),
            trailing: const Icon(Icons.navigate_next),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddFriendPage(
                    currentUserName: currentUserName,
                    currentUserId: currentUserId,
                    addFriendRequest: _addFriendRequest, // 콜백 함수 전달
                  ),
                ),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.group),
            title: Text('친구 목록'),
            trailing: Icon(Icons.navigate_next),
          ),
          ListTile(
            leading: const Icon(Icons.pending),
            title: const Text('요청 대기'),
            trailing: const Icon(Icons.navigate_next),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FriendRequestsPage(
                    friendRequests: friendRequests,
                    acceptFriendRequest: _acceptFriendRequest,
                    declineFriendRequest: _declineFriendRequest,
                  ),
                ),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.person_add_disabled),
            title: Text('친구 편집'),
            trailing: Icon(Icons.navigate_next),
          ),
        ],
      ),
    );
  }
}
