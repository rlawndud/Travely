import 'package:flutter/foundation.dart';
import 'package:travley/appbar/friend/FriendRequestModel.dart';

class FriendListProvider with ChangeNotifier {
  List<FriendRequest> _friendList = [];

  List<FriendRequest> get friendList => _friendList;

  void updateFriendList(List<FriendRequest> newList) {
    _friendList = newList;
    notifyListeners();
  }
}