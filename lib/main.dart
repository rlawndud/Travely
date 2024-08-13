import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test2/value/global_variable.dart';
import 'package:test2/home.dart';
import 'package:test2/login.dart';
import 'package:test2/model/member.dart';
import 'package:test2/signup.dart';
import 'package:test2/splash.dart';
import 'package:test2/appbar/friend/User_Provider.dart';
import 'package:provider/provider.dart';
import 'package:test2/appbar/friend/FriendlistManagement.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FriendListManagement()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: GlobalVariable.navigatorKey,
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

Route? generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case '/home':
      return MaterialPageRoute(builder: (context) {
        var map = routeSettings.arguments as Map<String, dynamic>;
        Member user = map['user'] as Member;

        // UserProvider에 사용자 정보 설정
        context.read<UserProvider>().setUser(user.id, user.name);

        return Home(user: user);
      },
        settings: routeSettings,
      );
    default:
      return null;
  }
}
