import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoLogin{
  static String PREFERENCES_NAME = 'auto_login';

  Future<SharedPreferences> getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  void setLoginInfo(RxBool state, String id, String pw)async{
    final SharedPreferences prefs = getPreferences as SharedPreferences;
    if(state.isTrue){
      prefs.setString('id', id);
      prefs.setString('password', pw);
    }
    else{
      prefs.clear();
    }
  }

  List<String?> getLoginInfo(){
    List<String?> idPassword = [];
    try{
      SharedPreferences prefs = getPreferences() as SharedPreferences;
      String? Id = prefs.getString('id');
      String? Pw = prefs.getString('password');
      idPassword[0] = Id;
      idPassword[1] = Pw;
    }catch(e){
      e.printError();
    }
    return idPassword;
  }
}