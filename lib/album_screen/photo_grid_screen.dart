import 'package:flutter/material.dart';
import 'package:test2/album_screen/photo_detail_screen.dart';
import 'package:test2/model/memberImg.dart';
import 'package:test2/model/picture.dart';
import 'package:test2/model/team.dart';


class PhotoGridScreen extends StatefulWidget {
  final String teamName;
  final String category;
  final String subCategory;
  final List<Map<String, dynamic>> teamMembers;

  const PhotoGridScreen({
    super.key,
    required this.teamName,
    required this.category,
    required this.subCategory,
    required this.teamMembers,
  });

  @override
  _PhotoGridScreenState createState() => _PhotoGridScreenState();
}

class _PhotoGridScreenState extends State<PhotoGridScreen> {
  final PicManager _picManager = PicManager();
  final TeamManager _teamManager = TeamManager();
  List<PictureEntity> _filteredPictures = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
    _picManager.addListener(_onPicturesChanged);
  }

  @override
  void dispose() {
    _picManager.removeListener(_onPicturesChanged);
    super.dispose();
  }

  void _onPicturesChanged() {
    _loadImages();
  }

  void _loadImages() {
    final pictures = _picManager.getPictureList();
    setState(() {
      _filteredPictures = _filterPictures(pictures);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} - ${widget.subCategory} 앨범'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: _filteredPictures.isEmpty
          ? Center(child: Text('사진을 찾을 수 없습니다'))
          : GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: _filteredPictures.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageDetailScreen(
                    pictures: _filteredPictures,
                    initialIndex: index,
                    teamName: widget.teamName,
                    category: widget.category,
                    subCategory: widget.subCategory,
                  ),
                ),
              );
            },
            child: Image.memory(
              BytesToImage(_filteredPictures[index].img_data),
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          );
        },
      ),
    );
  }

  List<PictureEntity> _filterPictures(List<PictureEntity> pictures) {
    return pictures.where((picture) {
      bool isTeam = _teamManager.getTeamNameByTeamNo(picture.team_num) == widget.teamName;
      if (widget.category == '전체사진') {
        return isTeam;
      } else if (widget.category == '지역') {
        if (widget.subCategory == '기타 지역') {
          List<String> mainRegions = ['서울', '대전', '부산', '인천', '대구', '울산', '광주', '제주도'];
          return isTeam && !mainRegions.any((region) => picture.location.contains(region));
        }
        return isTeam && picture.location.contains(widget.subCategory);
      } else if (widget.category == '계절') {
        return isTeam && picture.season == widget.subCategory;
      } else if (widget.category == '멤버'){
        return isTeam && picture.pre_face.contains(widget.subCategory);
      } else if (widget.category == '촬영자'){
        // 아이디 검색 및 이름 폴더
        var matchingMember = widget.teamMembers.firstWhere(
              (member) => member['id'] == picture.user_id,
          orElse: () => {'name': '알 수 없음'},
        );
        return isTeam && matchingMember['name'] == widget.subCategory;
      }
      return false;
    }).toList();
  }
}