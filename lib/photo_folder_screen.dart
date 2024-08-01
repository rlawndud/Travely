import 'package:flutter/material.dart';
import 'album_detail_page.dart'; // Ensure this path is correct

class PhotoFolderScreen extends StatelessWidget {
  const PhotoFolderScreen({Key? key}) : super(key: key);

  static const List<String> folderImages = [
    'assets/images/background.jpg',
    'assets/images/season.jpg',
    'assets/images/region.jpg',
    'assets/images/team_album.jpg',
  ];

  static const List<String> folderTitles = [
    '배경',
    '계절',
    '지역',
    '팀 별 앨범',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 폴더'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of columns
          crossAxisSpacing: 10.0, // Horizontal space between columns
          mainAxisSpacing: 10.0, // Vertical space between rows
        ),
        padding: const EdgeInsets.all(10.0),
        itemCount: folderImages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Navigate to AlbumDetailPage when an album is tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AlbumDetailPage(
                    albumTitle: folderTitles[index],
                    albumImages: _getAlbumImages(index),
                  ),
                ),
              );
            },
            child: Card(
              elevation: 5,
              child: GridTile(
                child: Image.asset(
                  folderImages[index],
                  fit: BoxFit.cover,
                ),
                footer: GridTileBar(
                  backgroundColor: Colors.black54,
                  title: Text(
                    folderTitles[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Function to return a list of images for each album
  List<String> _getAlbumImages(int index) {
    switch (index) {
      case 0: // 배경
        return ['assets/images/background_mountain.jpg', 'assets/images/background_sea.jpg', 'assets/images/background_cafe.jpg', 'assets/images/background_pool.jpg', 'assets/images/background_etc.jpg'];
      case 1: // 계절
        return ['assets/images/season_spring.jpg', 'assets/images/season_summer.jpg', 'assets/images/season_fall.jpg', 'assets/images/season_winter.jpg'];
      case 2: // 지역
        return ['assets/images/region_seoul.jpg', 'assets/images/region_daejeon.jpg', 'assets/images/region_busan.jpg', 'assets/images/region_daegu.jpg', 'assets/images/region_ulsan.jpg', 'assets/images/region_gwangju.jpg', 'assets/images/region_incheon.jpg', 'assets/images/region_jeju.jpg'];
      case 3: // 팀 별 앨범
      // 여기에서는 팀 생성 시 동적으로 추가된 앨범들을 반환해야 합니다.
      // 예시로 'team_album_1.jpg', 'team_album_2.jpg' 등
        return ['assets/images/team_album_1.jpg', 'assets/images/team_album_2.jpg'];
      default:
        return [];
    }
  }
}
