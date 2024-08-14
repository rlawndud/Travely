import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test2/model/member.dart';
import 'package:test2/model/team.dart';
import 'package:test2/network/web_socket.dart';
import 'package:test2/appbar/friend/AddFriendPage.dart';
import 'package:test2/appbar/friend/FriendListPage.dart';
import 'package:test2/appbar/friend/FriendRequestsPage.dart';
import 'package:test2/appbar/friend/FriendEditPage.dart';
import 'package:test2/appbar/friend/FriendRequestModel.dart';
import 'package:test2/appbar/friend/User_Provider.dart';

class Friend extends StatefulWidget {
  final Member user;
  const Friend({super.key, required this.user});

  @override
  _FriendState createState() => _FriendState();
}

class _FriendState extends State<Friend> {
  final WebSocketService _webSocketService = WebSocketService();
  List<FriendRequest> acceptedFriends = [];
  List<FriendRequest> friendRequests = [];

  late String currentUserId;
  late String currentUserName;

  @override
  void initState() {
    super.initState();
    _webSocketService.init();
    _fetchFriendRequests();
    _webSocketService.addListener(_handleWebSocketMessage);
    currentUserId = widget.user.id;
    currentUserName = widget.user.name;
  }

  void _handleWebSocketMessage(Map<String, dynamic> data) {
    if (data.containsKey('command')) {
      if(mounted){
        setState(() {
          // 데이터를 기반으로 UI 업데이트
        });
      }
    }
  }

  void _fetchFriendRequests() async {
    try {
      final response = await _webSocketService.refreshAddFriend(currentUserId);

      if (response['error'] == null) {
        setState(() {
          final toIds = response['to_ids'] as List<dynamic>;
          final toNames = response['to_names'] as List<dynamic>;

          //서버로부터 받은 정보를 이용해 리스트 업데이트
          friendRequests = List<FriendRequest>.generate(
            toIds.length,
                (index) => FriendRequest(id: toIds[index] as String, name: toNames[index] as String),
          );
        });
      } else {
        print('친구 요청 로드 실패: ${response['error']}');
      }
    } catch (e) {
      print('Error loading friend requests: $e');
    }
  }


  void _deleteFriend(FriendRequest friend) async {
    try {
      final response = await _webSocketService.DeleteFriend(currentUserId, friend.id);
      if (response['error'] == null) {
        setState(() {
          acceptedFriends.remove(friend);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${friend.name}을 친구목록에서 삭제하였습니다')),
        );
      }
    } catch (e) {
      debugPrint('Error removing friend: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  ),
                ),
              ).then((_) => _fetchFriendRequests());
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
                    currentUserId: currentUserId,
                    webSocketService: _webSocketService,
                    currentTeam: TeamManager().currentTeam,
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
                    currentUserId: currentUserId,
                    onFriendAccepted: (request) {
                      setState(() {
                        acceptedFriends.add(request);
                      });
                    },
                  ),
                ),
              ).then((_) => _fetchFriendRequests());
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
                    acceptedFriends: acceptedFriends,
                    removeFriend: _deleteFriend,
                    currentUserId: currentUserId,  // 추가
                    webSocketService: _webSocketService,  // 추가
                  ),
                ),
              ).then((_) => _fetchFriendRequests());
            },
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    print('Disposing Friend state');
    _webSocketService.removeListener(_handleWebSocketMessage);
    super.dispose();
  }
}