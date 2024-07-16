import 'package:flutter/material.dart';
import 'package:test2/home.dart';
import 'package:test2/login.dart';
import 'package:test2/album/photo_folder_screen.dart';
import 'package:test2/signup.dart';
import 'package:test2/splash.dart';


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
      },
    );
  }
}


