import 'package:flutter/material.dart';
//import 'package:test2/TeamSettingScreen.dart';
//import 'package:test2/image_upload_page.dart';
//import 'package:test2/album/photo_folder_screen.dart';
import 'package:test2/My_Page.dart';
import 'package:test2/Settings.dart';

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
              title: Text('𝒮𝓃𝒶𝓅 𝒩ℴ𝓉ℯ'),
              centerTitle: true,
              elevation: 0.0,
              backgroundColor: Colors.blueAccent,
              actions: [
                IconButton(
                onPressed: () {},
                  icon: Icon(Icons.search)
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.person_add_alt_sharp),
                )
              ],
            ),
            drawer: Drawer(
              child: ListView(
                children: [
                  UserAccountsDrawerHeader(
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: AssetImage('assets/cat.jpg'),
                    ),
                    accountName: Text('R 2 B'),
                    accountEmail: Text('abc12345@naver.com'),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent[100],
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15.0),
                        bottomRight: Radius.circular(15.0),
                      ),
                    ),
                    onDetailsPressed: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    iconColor: Colors.black38,
                    focusColor: Colors.black38,
                    title: Text('My Page'),
                    onTap: () {
                      Navigator.push(
                          context,
                        MaterialPageRoute(builder: (context) => const MyPage()),
                      );
                    },
                    trailing: Icon(Icons.navigate_next),
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    iconColor: Colors.black38,
                    focusColor: Colors.black38,
                    title: Text('Settings'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Settings()),
                      );
                    },
                    trailing: Icon(Icons.navigate_next),
                  ),
                  ListTile(
                    leading: Icon(Icons.question_answer),
                    iconColor: Colors.black38,
                    focusColor: Colors.black38,
                    title: Text('도움말'),
                    onTap: () {},
                    trailing: Icon(Icons.navigate_next),
                  ),
                ],
              ),
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
