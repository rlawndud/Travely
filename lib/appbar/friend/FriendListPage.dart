import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'FriendRequestModel.dart';
import 'FriendlistManagement.dart';
import 'package:test2/network/web_socket.dart';

class FriendListPage extends StatefulWidget {
  final String currentUserId;
  final WebSocketService webSocketService;
  final String currentTeam;

  const FriendListPage({
    super.key,
    required this.currentUserId,
    required this.webSocketService,
    required this.currentTeam,
  });

  @override
  _FriendListPageState createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {
  late final WebSocketService _webSocketService;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _webSocketService = widget.webSocketService;
    _loadAcceptedFriends();
  }

  Future<void> _loadAcceptedFriends() async {
    try {
      final response = await _webSocketService.getMyFriend(widget.currentUserId);

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
        List<FriendRequest> acceptedFriends = [];
        for (int i = 0; i < myFriendsId.length; i++) {
          final id = myFriendsId[i] as String;
          final name = myFriendsName[i] as String;
          acceptedFriends.add(FriendRequest(id: id, name: name));
        }

        // FriendListManagement를 사용하여 친구 목록 업데이트
        Provider.of<FriendListManagement>(context, listen: false)
            .updateFriendList(acceptedFriends);

        setState(() {
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


  void _inviteToTeam() async {
    try {
      final friendListManagement =
      Provider.of<FriendListManagement>(context, listen: false);
      final List<String> selectedFriends = friendListManagement.selectedFriendIds.toList();

      if (selectedFriends.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('초대할 친구를 선택하세요.')),
        );
        return;
      }

      // 팀에 친구를 초대하는 로직을 여기서 구현
      // 예: _teamManager.inviteTeamMember(widget.currentTeam, friendId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('초대가 완료되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('초대에 실패했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 목록'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.group_add),
            onPressed: _inviteToTeam,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Consumer<FriendListManagement>(
        builder: (context, friendListManagement, child) {
          return friendListManagement.friendList.isEmpty
              ? Center(child: Text('수락된 친구가 없습니다.'))
              : ListView.builder(
            itemCount: friendListManagement.friendList.length,
            itemBuilder: (context, index) {
              final friend = friendListManagement.friendList[index];
              final isSelected =
              friendListManagement.selectedFriendIds.contains(friend.id);

              return ListTile(
                title: Text(friend.name), // 친구 이름을 표시
                subtitle: Text(friend.id), // 친구 ID를 표시
                trailing: Checkbox(
                  value: isSelected,
                  onChanged: (bool? value) {
                    // 상태를 업데이트하고 UI를 갱신
                    friendListManagement.toggleSelection(friend.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
