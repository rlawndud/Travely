import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test2/model/userLoginState.dart';

class AutoLogin{
  static String PREFERENCES_NAME = 'auto_login';

  static final AutoLogin _instance = AutoLogin._internal();
  final Future<SharedPreferences> _manager = SharedPreferences.getInstance();

  AutoLogin._internal(){}

  factory AutoLogin(){
    return _instance;
  }

  Future<void> setLoginInfo(RxBool state, UserLoginState IdPw)async{
    final manager = await _manager;
    if(state.isTrue){
      manager.setString('id', IdPw.id);
      manager.setString('password', IdPw.password);
    }
    else{
      manager.clear();
    }
  }

  Future<void> setLoginState(RxBool state) async {
    final manager = await _manager;
    if (state.isFalse) {
      manager.clear();
    }
  }

  Future<List<String>> getLoginInfo()async{
    final manager = await _manager;
    return [manager.getString('id')??'',manager.getString('password')??''];
  }
}
