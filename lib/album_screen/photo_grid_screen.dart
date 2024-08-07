import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test2/album_screen/photo_detail_screen.dart';
import 'package:test2/model/memberImg.dart';
import 'package:test2/model/picture.dart';
import 'package:test2/model/team.dart';


class PhotoGridScreen extends StatefulWidget {
  final String teamName;
  final String category;
  final String subCategory;

  const PhotoGridScreen({
    Key? key,
    required this.teamName,
    required this.category,
    required this.subCategory,
  }) : super(key: key);

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
          ? Center(child: Text('No images found'))
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
                    picture: _filteredPictures[index],
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
        //picture.location이랑 비교할 듯
        return isTeam && picture.pre_background == widget.subCategory;
      } else if (widget.category == '계절') {
        // 계절에 대한 필터링 로직 추가 필요
        // picture.date로 직접 처리해도 되고, 계절 구분해놓은 데이터 처리해도 되고
        return isTeam;
      } else if (widget.category == '배경') {
        return isTeam && picture.pre_background == widget.subCategory;
      } else if (widget.category == '멤버'){
        return isTeam && picture.pre_face.contains(widget.subCategory);
      }
      return false;
    }).toList();
  }
}