import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'FriendRequestModel.dart';
import 'package:travley/network/web_socket.dart';
import 'FriendlistManagement.dart';

class FriendEditPage extends StatefulWidget {
  final List<FriendRequest> acceptedFriends;
  final void Function(FriendRequest) removeFriend;
  final String currentUserId;
  final WebSocketService webSocketService;

  const FriendEditPage({
    super.key,
    required this.acceptedFriends,
    required this.removeFriend,
    required this.currentUserId,
    required this.webSocketService,
  });

  @override
  _FriendEditPageState createState() => _FriendEditPageState();
}

class _FriendEditPageState extends State<FriendEditPage> {
  bool isLoading = true;
  late List<FriendRequest> updatedFriends;

  @override
  void initState() {
    super.initState();
    updatedFriends = List.from(widget.acceptedFriends); // Initializing updatedFriends
    _loadAcceptedFriends();
  }

  Future<void> _loadAcceptedFriends() async {
    try {
      final response = await widget.webSocketService.getMyFriend(widget.currentUserId);

      if (response['error'] == null) {
        // 서버에서 받은 JSON 데이터
        final myFriendsId = response['my_friends_id'] as List<dynamic>? ?? [];
        final myFriendsName = response['my_fridend_name'] as List<dynamic>? ?? [];

        // 데이터 길이 확인
        if (myFriendsId.length != myFriendsName.length) {
          print('ID와 이름 목록의 길이가 일치하지 않습니다.');
          return;
        }

        // FriendRequest 객체 생성
        List<FriendRequest> friends = [];
        for (int i = 0; i < myFriendsId.length; i++) {
          final id = myFriendsId[i] as String;
          final name = myFriendsName[i] as String;
          friends.add(FriendRequest(id: id, name: name));
        }

        // FriendListManagement를 사용하여 친구 목록 업데이트
        Provider.of<FriendListManagement>(context, listen: false)
            .updateFriendList(friends);

        setState(() {
          updatedFriends = friends; // Update the list to reflect new data
          isLoading = false;
        });
      } else {
        print('친구 목록 로드 실패: ${response['error']}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading accepted friends: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _removeFriendFromServer(String fromId, String toId) async {
    try {
      final response = await widget.webSocketService.DeleteFriend(fromId, toId);
      if (response['error'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('친구가 성공적으로 삭제되었습니다.')),
        );
        setState(() {
          updatedFriends.removeWhere((friend) => friend.id == toId);
        });
      } else {
        print('친구 삭제 실패: ${response['error']}');
      }
    } catch (e) {
      print('Error removing friend from server: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 편집'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: updatedFriends.length,
        itemBuilder: (context, index) {
          final friend = updatedFriends[index];
          return Dismissible(
            key: Key(friend.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('삭제 확인'),
                    content: Text('${friend.name} 님을 삭제하겠습니까?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('삭제'),
                      ),
                    ],
                  );
                },
              );
            },
            onDismissed: (direction) async {
              await _removeFriendFromServer(widget.currentUserId, friend.id);
              widget.removeFriend(friend);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${friend.name} 님이 삭제되었습니다.')),
              );
            },
            child: ListTile(
              title: Text(friend.name),
              subtitle: Text(friend.id),
            ),
          );
        },
      ),
    );
  }
}
