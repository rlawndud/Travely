import 'package:flutter/material.dart';
import 'package:test2/appbar/friend/AddFriendPage.dart'; // 오타 수정
import 'FriendRequestsPage.dart';
import 'FriendRequestModel.dart';
import 'FriendListPage.dart';
import 'FriendEditPage.dart'; // 새로 추가된 파일

class Friend extends StatefulWidget {
  const Friend({super.key}); // const 생성자

  @override
  _FriendState createState() => _FriendState();
}

class _FriendState extends State<Friend> {
  List<FriendRequest> friendRequests = [];
  List<FriendRequest> acceptedFriends = []; // 수락된 친구 리스트

  void _addFriendRequest(String senderId, String senderName) {
    setState(() {
      friendRequests.add(FriendRequest(senderId: senderId, senderName: senderName));
    });
  }

  void _acceptFriendRequest(FriendRequest request) {
    setState(() {
      friendRequests.remove(request);
      acceptedFriends.add(request); // 수락된 친구를 리스트에 추가
    });
    print('Accepted friend request from: ${request.senderName}');
  }

  void _declineFriendRequest(FriendRequest request) {
    setState(() {
      friendRequests.remove(request);
    });
    print('Declined friend request from: ${request.senderName}');
  }

  void _removeFriend(FriendRequest friend) {
    setState(() {
      acceptedFriends.remove(friend); // 친구 삭제
    });
    print('Removed friend: ${friend.senderName}');
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
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('친구 목록'),
            trailing: const Icon(Icons.navigate_next),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FriendListPage(
                    acceptedFriends: acceptedFriends, // 수락된 친구 리스트 전달
                  ),
                ),
              );
            },
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
          ListTile(
            leading: const Icon(Icons.person_add_disabled),
            title: const Text('친구 편집'),
            trailing: const Icon(Icons.navigate_next),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FriendEditPage(
                    acceptedFriends: acceptedFriends, // 수락된 친구 리스트 전달
                    removeFriend: _removeFriend, // 친구 삭제 콜백 함수 전달
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
