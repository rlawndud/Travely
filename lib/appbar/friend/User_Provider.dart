import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  String _userId = '';
  String _userName = '';

  String get userId => _userId;
  String get userName => _userName;

  void setUser(String userId, String userName) {
    _userId = userId;
    _userName = userName;
    notifyListeners();
  }
}
