import 'package:flutter/material.dart';
import 'package:test2/network/web_socket.dart';
import 'FriendRequestModel.dart';

class FriendRequestsPage extends StatefulWidget {
  final String currentUserId;
  final Function(FriendRequest) onFriendAccepted;

  const FriendRequestsPage({
    Key? key,
    required this.currentUserId,
    required this.onFriendAccepted,
  }) : super(key: key);

  @override
  _FriendRequestsPageState createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  final WebSocketService _webSocketService = WebSocketService();
  List<FriendRequest> friendRequests = [];
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = widget.currentUserId;
    _loadFriendRequests();
  }

  Future<void> _loadFriendRequests() async {
    try {
      final response = await _webSocketService.refreshAddFriend(currentUserId);

      print('Server response: $response');  // 응답 로그 출력

      if (response.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('친구 요청 로드 실패: ${response['error']}')),
        );
        
      } else {
        setState(() {
          final toIds = response['to_ids'] as List<dynamic>;
          final toNames = response['to_names'] as List<dynamic>;

          // 서버로부터 받은 정보를 이용해 리스트 업데이트
          friendRequests = List<FriendRequest>.generate(
            toIds.length,
                (index) => FriendRequest(id: toIds[index] as String, name: toNames[index] as String),
          );
        });
      }
    } catch (e) {
      print('Error loading friend requests: $e');
    }

  }

  void _acceptFriendRequest(FriendRequest request) async {
    try {
      final response = await _webSocketService.acceptFriendRequest(
        request.id,
        currentUserId,
        true,
      );
      print('메롱티비');
      print('Server response after accept: $response');  // 응답 로그 출력

      if (response.containsKey('error') && response['error'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('친구 요청 수락 실패: ${response['error']}')),
        );
        print('깔깔티비');
        return;

      }

      setState(() {
        friendRequests.remove(request);
      });
      widget.onFriendAccepted(request); // 친구 수락 시 콜백 호출
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${request.name}님의 친구 요청을 수락했습니다.')),
      );
    } catch (e) {
      print('Error accepting friend request: $e');  // 예외 로그 출력
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('친구 요청 수락 중 오류 발생')),
      );
    }
  }


  void _declineFriendRequest(FriendRequest request) async {
    try {
      final response = await _webSocketService.declineFriendRequest(
        request.id,
        currentUserId,
      );

      print('Server response after decline: $response');  // 응답 로그 출력

      if (response['error'] == null) {
        setState(() {
          friendRequests.remove(request);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${request.name}님의 친구 요청을 거절했습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('친구 요청 거절 실패: ${response['error']}')),
        );
      }
    } catch (e) {
      print('Error declining friend request: $e');  // 예외 로그 출력
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 요청'),
        backgroundColor: Colors.blueAccent,
      ),
      body: friendRequests.isEmpty
          ? Center(child: Text('친구 요청이 없습니다.'))
          : ListView.builder(
        itemCount: friendRequests.length,
        itemBuilder: (context, index) {
          final request = friendRequests[index];
          return ListTile(
            title: Text(request.name),
            subtitle: Text(request.id),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _acceptFriendRequest(request),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _declineFriendRequest(request),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
