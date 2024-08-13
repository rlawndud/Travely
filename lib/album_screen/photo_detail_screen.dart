import 'package:flutter/material.dart';
import 'package:test2/model/memberImg.dart';
import 'package:test2/model/picture.dart';

class ImageDetailScreen extends StatefulWidget {
  final List<PictureEntity> pictures;
  final int initialIndex;
  final String teamName;
  final String category;
  final String subCategory;

  const ImageDetailScreen({
    Key? key,
    required this.pictures,
    required this.initialIndex,
    required this.teamName,
    required this.category,
    required this.subCategory,
  }) : super(key: key);

  @override
  _ImageDetailScreenState createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Detail'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.pictures.length,
        allowImplicitScrolling: true,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final picture = widget.pictures[index];
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Hero(
                    tag: 'imageHero${picture.img_num}',
                    child: Image.memory(
                      BytesToImage(picture.img_data),
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                      cacheWidth: 1080, // Adjust based on your needs
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _getImageAnalysis(picture),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 50,
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, size: 18,),
            onPressed: _currentIndex > 0
                ? () {
              _pageController.previousPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
                : null,
          ),
          Text('${_currentIndex + 1} / ${widget.pictures.length}'),
          IconButton(
            icon: Icon(Icons.arrow_forward, size: 18,),
            onPressed: _currentIndex < widget.pictures.length - 1
                ? () {
              _pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
                : null,
          ),
        ],
      ),
      ),
    );
  }

  String _getImageAnalysis(PictureEntity picture) {
    return picture.printPredict();
  }
}