import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test2/album_screen/photo_detail_screen.dart';
import 'package:test2/model/memberImg.dart';
import 'package:test2/model/picture.dart';
import 'package:test2/model/team.dart';

class SearchPage extends StatefulWidget {
  final String initialQuery;
  final int? teamNo;
  const SearchPage({Key? key, required this.initialQuery, this.teamNo}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<PictureEntity> _searchResults = [];
  final PicManager _picManager = PicManager();
  final DateFormat _dateFormat = DateFormat('yyyy/MM/dd HH:mm:ss');

  @override
  void initState() {
    super.initState();
    print('검색페이지 : ${widget.initialQuery}');
    _performSearch(widget.initialQuery);
  }

  @override
  void didUpdateWidget(SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQuery != oldWidget.initialQuery || widget.teamNo != oldWidget.teamNo) {
      _performSearch(widget.initialQuery);
    }
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    print('검색페이지 - performSearch : $query');
    /*final queryWords = query.trim().split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty).toList();

    setState(() {
      _searchResults = _picManager.getPictureList().where((pic) {
        return queryWords.every((word) => _matchDate(pic.date, word) ||
            _containsWord(pic.location, word) ||
            pic.pre_face.any((face) => _containsWord(face, word)) ||
            _containsWord(pic.pre_background, word) ||
            _containsWord(pic.pre_caption, word)
        );
      }).toList();
    });*/

    final queryGroups = query.split(',').map((group) => group.trim().split(RegExp(r'\s+')));

    setState(() {
      _searchResults = _picManager.getPictureList().where((pic) {
        bool teamMatch = widget.teamNo == null || pic.team_num == widget.teamNo;
        return teamMatch && queryGroups.every((group) {
          return group.any((word) =>
          pic.pre_face.any((face) => _containsWord(face, word)) ||
              _containsWord(pic.date, word, isDate: true) ||
              _containsWord(pic.location, word) ||
              _containsWord(pic.pre_background, word) ||
              _containsWord(pic.pre_caption, word)
          );
        });
      }).toList();
    });

    print('검색어: $queryGroups');
    print('검색 결과 수: ${_searchResults.length}');
  }

  bool _containsWord(String source, String word, {bool isDate = false}) {
    if (isDate) {
      return _matchDate(source, word);
    }else{
      return source.contains(word);
    }
  }

  bool _matchDate(String dateString, String query) {
    try{
      DateTime date = _dateFormat.parse(dateString);

      List<String> possibleFormats = [
        'yyyy/MM/dd', 'yyyy.MM.dd', 'yyyy-MM-dd',
        'yyyy년 MM월 dd일', 'yyyy년MM월dd일'
      ];
      for (String format in possibleFormats) {
        try {
          DateTime queryDate = DateFormat(format).parse(query);
          return date.year == queryDate.year &&
              date.month == queryDate.month &&
              date.day == queryDate.day;
        } catch (_) {
          // 이 형식들로 파싱 실패
        }
      }

      String year = date.year.toString();
      String month = date.month.toString().padLeft(2, '0');
      String day = date.day.toString().padLeft(2, '0');

      return year == query || '$year년' == query ||
          '$month월' == query || '${date.month}월' == query ||
          '$day일' == query || '${date.day}일' == query;
    } catch (e) {
      print('picEntity의 date 파싱실패 : $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 4),
        Expanded(
            child: _searchResults.isEmpty
            ? Center(child: Text(widget.initialQuery.isEmpty ? '검색어를 입력하세요' : '검색 결과가 없습니다'))
            : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _showImageDetails(_searchResults, index);
                  },
                  child: Hero(
                    tag: 'imageHero${_searchResults[index].img_num}',
                    child: Image.memory(
                      BytesToImage(_searchResults[index].img_data),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('검색 결과: ${_searchResults.length}개'),
        ),
      ],
    );
  }

  void _showImageDetails(List<PictureEntity> pictures, int index) {
    final TeamManager teamManager = TeamManager();
    final String teamName = teamManager.getTeamNameByTeamNo(pictures[index].team_num) ?? 'Unknown Team';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageDetailScreen(
          pictures: pictures,
          initialIndex: index,
          teamName: teamName,
          category: 'Search',
          subCategory: '',
        ),
      ),
    );
  }
}
