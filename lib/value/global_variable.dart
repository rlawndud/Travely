import 'package:flutter/material.dart';

class GlobalVariable{
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> globalScaffoldKey = GlobalKey<ScaffoldMessengerState>();

  static bool _isTravel = true;
  static bool get isTavel => _isTravel;

  static void setTravel(bool value){
    _isTravel = value;
  }
}