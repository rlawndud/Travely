import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:test2/model/team.dart';
import 'FriendRequestModel.dart';
import 'FriendlistManagement.dart';
import 'package:test2/network/web_socket.dart';
import 'package:test2/value/global_variable.dart';

// FriendListPage 클래스 정의
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
  final WebSocketService _webSocketService = WebSocketService();
  final teamManager = TeamManager();
  bool isLoading = true;
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = widget.currentUserId;
    _loadAcceptedFriends();
  }

  Future<void> _loadAcceptedFriends() async {
    try {
      final response = await _webSocketService.getMyFriend(currentUserId);

      if (response['error'] == null) {
        final myFriendsId = response['my_friends_id'] as List<dynamic>? ?? [];
        final myFriendsName = response['my_fridend_name'] as List<dynamic>? ?? [];

        if (myFriendsId.length != myFriendsName.length) {
          print('ID와 이름 목록의 길이가 일치하지 않습니다.');
          return;
        }

        List<FriendRequest> acceptedFriends = [];
        for (int i = 0; i < myFriendsId.length; i++) {
          final id = myFriendsId[i] as String;
          final name = myFriendsName[i] as String;
          acceptedFriends.add(FriendRequest(id: id, name: name));
        }

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

  void _inviteToTeams() async {
    try {
      final friendListManagement = Provider.of<FriendListManagement>(context, listen: false);

      String selectedFriends = '';

      for(var friend in friendListManagement.selectedFriendIds.toList()){
        selectedFriends += friend + ',';
      }

      if (selectedFriends.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('초대할 친구를 선택하세요.')),
        );
        return;
      }

      int teamNo = TeamManager().getTeamNoByTeamName(widget.currentTeam)!;

      GlobalVariable.setTravel(false); // 모델 생성 전까지 버튼 비활성화
      setState(() {
      });

      // 웹소켓을 통해 팀 멤버 추가 요청
      final response = await _webSocketService.addTeamMembers(
          teamNo,
          widget.currentTeam,         // 팀 이름, 실제 값으로 대체 필요
          selectedFriends,
          widget.currentUserId
      );

      if (response['result'] == 'True') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('초대가 완료되었습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('초대에 실패했습니다: ${response['message']}')),
        );
      }
      GlobalVariable.setTravel(true);
      if(mounted){
        setState(() {
        });
      }
    } catch (e) {
      e.printError;
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
            onPressed: _inviteToTeams,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Consumer<FriendListManagement>(
        builder: (context, friendListManagement, child) {
          return Column(
            children: [
              // 친구 목록 표시
              Expanded(
                child: friendListManagement.friendList.isEmpty
                    ? Center(child: Text('수락된 친구가 없습니다.'))
                    : ListView.builder(
                  itemCount: friendListManagement.friendList.length,
                  itemBuilder: (context, index) {
                    final friend = friendListManagement.friendList[index];
                    final isSelected = friendListManagement.selectedFriendIds.contains(friend.id);

                    return ListTile(
                      title: Text(friend.name),
                      subtitle: Text(friend.id),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) {
                          friendListManagement.toggleSelection(friend.id);
                        },
                      ),
                    );
                  },
                ),
              ),
              Expanded(child: Container()),
              Text('현재 팀 : ${TeamManager().currentTeam}'),
              const SizedBox(height: 10),
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: GlobalVariable.isTavel?_inviteToTeams:null,
                  child: const Text('여행 시작', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),

                    disabledBackgroundColor: Colors.blue.withOpacity(0.30),
                    disabledForegroundColor: Colors.blue.withOpacity(0.30),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}
