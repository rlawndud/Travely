import 'package:flutter/material.dart';
import 'package:test2/image_upload_page.dart';

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
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: Text('share album App'),
            ),
            body: TabBarView(
              children: [
                ImageUploadePage(),
                Text('참여 그룹 화면'),
                Text('검색 화면'),
                Text('내 정보 화면'),
              ],
            ),
            bottomNavigationBar: TabBar(tabs: [
              Tab(
                icon: Icon(Icons.photo_library),
                text: '내 앨범',
              ),
              Tab(
                icon: Icon(Icons.groups),
                text: '참여 그룹',
              ),
              Tab(
                icon: Icon(Icons.search),
                text: '사진 찾기',
              ),
              Tab(
                icon: Icon(Icons.person),
                text: '내 정보',
              )
            ]),
          )),
    );
  }
}
