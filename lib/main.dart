import 'dart:io';

import 'package:flutter/material.dart';
import 'package:test2/home.dart';
import 'package:test2/login.dart';
import 'package:test2/model/member.dart';
import 'package:test2/signup.dart';
import 'package:test2/splash.dart';
import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/location_log.txt';
    final file = File(path);
    final timeStamp = DateTime.now().toIso8601String();
    final log = '[$timeStamp] Latitude: ${position.latitude}, Longitude: ${position.longitude}\n';

    await file.writeAsString(log, mode: FileMode.append);
    return Future.value(true);
  });
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
