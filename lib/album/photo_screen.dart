import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BackgroundScreen extends StatelessWidget  {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('배경'),
      ),
          body: Center(
            child: Text('배경 화면 내용'),
    )
    );
  }
}

class SeasonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('계절'),
      ),
      body: Center(
        child: Text('계절 화면 내용'),
      ),
    );
  }
}

class RegionScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('지역'),
      ),
      body: Center(
        child: Text('지역 화면 내용'),
      ),
    );
  }
}

class TeamAlbumScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('팀 별 앨범'),
      ),
      body: Center(
        child: Text('팀 별 앨범 화면 내용'),
      ),
    );
  }
}