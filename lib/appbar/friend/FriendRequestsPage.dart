import 'package:flutter/material.dart';
import 'FriendRequestModel.dart';

class FriendRequestsPage extends StatelessWidget {
  final List<FriendRequest> friendRequests;
  final Function(FriendRequest) acceptFriendRequest;
  final Function(FriendRequest) declineFriendRequest;

  const FriendRequestsPage({super.key,
    required this.friendRequests,
    required this.acceptFriendRequest,
    required this.declineFriendRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 요청'),
      ),
      body: ListView.builder(
        itemCount: friendRequests.length,
        itemBuilder: (context, index) {
          final request = friendRequests[index];
          return ListTile(
            title: Text(request.senderId),
            subtitle: Text(request.senderName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () => acceptFriendRequest(request),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => declineFriendRequest(request),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
