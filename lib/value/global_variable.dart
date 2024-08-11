import 'package:flutter/material.dart';

class GlobalVariable{
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

class GlobalScaffoldMessenger{
  static final GlobalKey<ScaffoldMessengerState> globalScaffoldKey = GlobalKey<ScaffoldMessengerState>();
}