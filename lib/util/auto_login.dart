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

  Future<Object> getLoginInfo()async{
    List<String?> idPassword = [null, null];
    try{
      SharedPreferences prefs = await getPreferences();
      String? Id = prefs.getString('id');
      String? Pw = prefs.getString('password');
      idPassword[0] = Id;
      idPassword[1] = Pw;

      return {
        'id': Id ?? '',
        'password': Pw ?? '',
      };
    }catch(e){
      e.printError();
    }
    return idPassword;
  }
}