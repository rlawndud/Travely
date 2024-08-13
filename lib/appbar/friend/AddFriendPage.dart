import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test2/network/web_socket.dart';

class AddFriendPage extends StatelessWidget {
  final String currentUserName;
  final String currentUserId;
  final WebSocketService webSocketService;

  AddFriendPage({
    Key? key,
    required this.currentUserName,
    required this.currentUserId,
    WebSocketService? webSocketService,
  })  : webSocketService = webSocketService ?? WebSocketService(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController friendIdController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 추가'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: friendIdController,
              decoration: InputDecoration(
                labelText: 'Friend ID',
                labelStyle: TextStyle(color: Colors.blueAccent),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final String friendId = friendIdController.text;
                if (friendId.isNotEmpty) {
                  try {
                    final response = await webSocketService.addFriend(currentUserId, friendId);
                    if (response['result'] == 'True') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Friend request sent to $friendId')),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${response['error']}')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('오류 발생')),
                    );
                    e.printError;
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('친구 ID는 비울 수 없습니다')),
                  );
                }
              },
              child: const Text('친구 추가'),
            ),
          ],
        ),
      ),
    );
  }
}
