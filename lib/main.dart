import 'package:flutter/material.dart';
import 'package:travley/value/global_variable.dart';
import 'package:travley/home.dart';
import 'package:travley/login.dart';
import 'package:travley/model/member.dart';
import 'package:travley/signup.dart';
import 'package:travley/splash.dart';
import 'package:provider/provider.dart';
import 'package:travley/appbar/friend/FriendlistManagement.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
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
      scaffoldMessengerKey: GlobalVariable.globalScaffoldMessengerKey,
      navigatorKey: GlobalVariable.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.white,
        primarySwatch: Colors.blue,
      ),
      builder: (context, child){
        return Scaffold(
          body: child,
        );
      },
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

        return Home(user: user);
      },
        settings: routeSettings,
      );
    default:
      return null;
  }
}
