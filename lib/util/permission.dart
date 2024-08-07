import 'package:permission_handler/permission_handler.dart';

class PermissionManager{
  static Future<bool> requestLocationPermission() async{
    var status = await Permission.location.status;
    if(status.isGranted){
      return true;
    }else if(status.isDenied){
      status = await Permission.location.request();
      return status.isGranted;
    }
    return false;
  }

  static Future<bool> requestCameraPermission() async{
    var status = await Permission.camera.status;
    if(status.isGranted){
      return true;
    }else if(status.isDenied){
      status = await Permission.camera.request();
      return status.isGranted;
    }
    return false;
  }

  static Future<void> checkAndRequestPermissions() async {
    bool locationGranted = await requestLocationPermission();
    bool cameraGranted = await requestCameraPermission();

    if (!locationGranted || !cameraGranted) {
      print('일부 권한이 거부되었습니다. 앱 기능이 제한될 수 있습니다.');
    }
  }
}