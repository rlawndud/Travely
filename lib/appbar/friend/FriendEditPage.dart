import 'package:flutter/material.dart';
import 'FriendRequestModel.dart';

class FriendEditPage extends StatelessWidget {
  final List<FriendRequest> acceptedFriends;
  final void Function(FriendRequest) removeFriend;

  const FriendEditPage({
    Key? key,
    required this.acceptedFriends,
    required this.removeFriend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 편집'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: acceptedFriends.length,
        itemBuilder: (context, index) {
          final friend = acceptedFriends[index];
          return Dismissible(
            key: Key(friend.senderId),
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
              final bool res = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('삭제 확인'),
                    content: Text('${friend.senderName} 님을 삭제하겠습니까?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // No
                        },
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // Yes
                        },
                        child: const Text('삭제'),
                      ),
                    ],
                  );
                },
              );
              return res;
            },
            onDismissed: (direction) {
              removeFriend(friend);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${friend.senderName} 님이 삭제되었습니다')),
              );
            },
            child: ListTile(
              title: Text(friend.senderName),
              subtitle: Text(friend.senderId),
            ),
          );
        },
      ),
    );
  }
}
