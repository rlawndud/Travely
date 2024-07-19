import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'chat used firebase',
      theme: ThemeData(primaryColor: Colors.white),
      home: DefaultTabController(
          length: 5,
          child: Scaffold(
            appBar: AppBar(
              title: Text('share album App'),
            ),
            body: TabBarView(
              children: [
                Text('팀'),
                Text('앨범'),
                Text('홈'),
                Text('촬영'),
                Text('AI텍스트'),
              ],
            ),
            bottomNavigationBar: TabBar(tabs: [
              Tab(
                icon: Icon(Icons.group, color: Colors.black),
                text: '팀',
              ),
              Tab(
                icon: Icon(Icons.photo_album, color: Colors.black),
                text: '앨범',
              ),
              Tab(
                icon: Icon(Icons.home, color: Colors.black),
                text: '홈',
              ),
              Tab(
                icon: Icon(Icons.camera_alt, color: Colors.black),
                text: '촬영',
              ),
              Tab(
                icon: Icon(Icons.edit_note, color: Colors.black),
                text: 'SnapNote',
              )
            ]),
          )),
    );
  }
}
