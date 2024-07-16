import 'package:flutter/material.dart';

class PhotoFolderScreen extends StatelessWidget {
  const PhotoFolderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('사진 폴더'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {},
              child: Text('배경'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('계절'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('지역'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('팀 별 앨범'),
            ),
          ],
        ),
      ),
    );
  }
}
