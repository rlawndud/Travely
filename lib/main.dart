// file: lib/main.dart

import 'package:flutter/material.dart';
import 'package:test2/home.dart';
import 'package:test2/login.dart';
import 'package:test2/album/photo_folder_screen.dart';
import 'package:test2/signup.dart';
import 'package:test2/splash.dart';
import 'package:test2/album/PhotoContract.dart'; // 변경된 경로에 맞게 import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Splash(),
      routes: {
        '/login': (context) => Login(),
        '/home': (context) => Home(),
        '/signup': (context) => Signup(),
        '/photo_folder_screen': (context) => PhotoFolderScreen(),
        '/PhotoContract': (context) => const PhotoContract(), // 새로 추가된 화면
      },
      // onGenerateRoute는 명시된 경로 외에 추가적인 경로 처리를 위해 사용
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (context) => Login());
          case '/home':
            return MaterialPageRoute(builder: (context) => Home());
          case '/signup':
            return MaterialPageRoute(builder: (context) => Signup());
          case '/photo_folder_screen':
            return MaterialPageRoute(builder: (context) => PhotoFolderScreen());
          case '/PhotoContract':
            return MaterialPageRoute(builder: (context) => const PhotoContract());
          default:
          // 없는 경로 요청 시 기본 화면으로 이동
            return MaterialPageRoute(builder: (context) => const Splash());
        }
      },
    );
  }
}
