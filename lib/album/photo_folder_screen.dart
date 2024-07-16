import 'package:flutter/material.dart';
import 'photo_screen.dart';

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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BackgroundScreen()),
                );
              },
              child: Text('배경'),
            ),
            ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SeasonScreen()),
                    );
              },
              child: Text('계절'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegionScreen()),
                );
              },
              child: Text('지역'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeamAlbumScreen()),
                );
              },
              child: Text('팀 별 앨범'),
            ),
          ],
        ),
      ),
    );
  }
}
