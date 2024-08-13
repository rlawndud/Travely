import 'package:flutter/foundation.dart';
import 'FriendRequestModel.dart';

class FriendListManagement with ChangeNotifier {
  // 싱글톤 인스턴스
  static final FriendListManagement _instance = FriendListManagement._internal();

  // 내부 생성자
  FriendListManagement._internal();

  // 팩토리 생성자: 싱글톤 인스턴스를 반환
  factory FriendListManagement() => _instance;

  // 친구 목록과 선택된 친구 ID들을 관리하는 변수
  List<FriendRequest> _friendList = [];
  Set<String> _selectedFriendIds = {};

  // 친구 목록 getter
  List<FriendRequest> get friendList => _friendList;

  // 선택된 친구 ID 목록 getter
  Set<String> get selectedFriendIds => _selectedFriendIds;

  // 친구 목록 업데이트 메서드
  void updateFriendList(List<FriendRequest> newList) {
    _friendList = newList;
    notifyListeners(); // 변경 사항을 알림
  }

  // 친구 선택/해제 토글 메서드
  void toggleSelection(String friendId) {
    if (_selectedFriendIds.contains(friendId)) {
      _selectedFriendIds.remove(friendId);
    } else {
      _selectedFriendIds.add(friendId);
    }
    notifyListeners(); // 변경 사항을 알림
  }

  // 선택된 친구 목록 초기화 메서드
  void clearSelection() {
    _selectedFriendIds.clear();
    notifyListeners(); // 변경 사항을 알림
  }
}
