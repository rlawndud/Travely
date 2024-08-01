import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoLogin{
  static String PREFERENCES_NAME = 'auto_login';

  static final AutoLogin _instance = AutoLogin._internal();
  final Future<SharedPreferences> _manager = SharedPreferences.getInstance();

  AutoLogin._internal(){}

  factory AutoLogin(){
    return _instance;
  }

  Future<void> setLoginInfo(RxBool state, String id, String pw)async{
    final manager = await _manager;
    if(state.isTrue){
      manager.setString('id', id);
      manager.setString('password', pw);
    }
    else{
      manager.clear();
    }
  }

  Future<List<String>> getLoginInfo()async{
    final manager = await _manager;
    return [manager.getString('id')??'',manager.getString('password')??''];
  }
}
