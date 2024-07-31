import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test2/home.dart';
import 'package:test2/login.dart';
import 'package:test2/model/member.dart';
import 'package:test2/signup.dart';
import 'package:test2/splash.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Splash(),
      routes: {
        '/login': (context) => Login(),
        '/signup': (context) => Signup(),
      },
      onGenerateRoute: (settings) => generateRoute(settings),
    );
  }
}

Route? generateRoute(RouteSettings routeSettings){
  switch(routeSettings.name){
    case '/home':
      return MaterialPageRoute(builder: (context){
        var map = routeSettings.arguments as Map<String, dynamic>;
        return Home(
          user: map['user'] as Member,
        );
      }, settings: routeSettings,);
    default:
      return null;
  }
}

