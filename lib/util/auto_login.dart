import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoLogin{
  static String PREFERENCES_NAME = 'auto_login';

  Future<SharedPreferences> getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  Future<void> setLoginInfo(RxBool state, String id, String pw)async{
    final SharedPreferences prefs = await getPreferences();
    if(state.isTrue){
      prefs.setString('id', id);
      prefs.setString('password', pw);
    }
    else{
      prefs.clear();
    }
  }

  Future<List<String>?> getLoginInfo()async{
    final prefs = await SharedPreferences.getInstance();
    final String? id = prefs.getString('id');
    final String? pw = prefs.getString('passwaord');

    if (id != null && pw != null) {
      return [id, pw];
    }
    return null;
  }
}