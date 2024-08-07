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
        if (widget.subCategory == '기타 지역') {
          List<String> mainRegions = ['서울', '대전', '부산', '인천', '대구', '울산', '광주', '제주도'];
          return isTeam && !mainRegions.any((region) => picture.location.contains(region));
        }
        return isTeam && picture.location.contains(widget.subCategory);
      } else if (widget.category == '계절') {
        return isTeam && picture.season == widget.subCategory;
      } else if (widget.category == '배경') {
        if (widget.subCategory == '기타') {
          List<String> mainBackgrounds = ['산', '바다'];
          return isTeam && !mainBackgrounds.contains(picture.pre_background);
        }
        return isTeam && picture.pre_background == widget.subCategory;
      } else if (widget.category == '멤버'){
        return isTeam && picture.pre_face.contains(widget.subCategory);
      }
      return false;
    }).toList();
  }
}