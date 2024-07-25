import 'package:flutter/material.dart';

class PhotoContract {
  final String title;

  PhotoContract(this.title);
}

class PhotoContractCard extends StatelessWidget {
  final PhotoContract Function() photoContract;

  PhotoContractCard({
    required this.photoContract,
    required this.modifier,
  });

  final Modifier modifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {
              // TODO: Navigate to Album Detail
            },
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Card(
                elevation: 4.0,
                child: Center(
                  // TODO: 앨범 대표사진 Grid 구현
                  child: Text('앨범 대표사진'),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              photoContract().title,
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: PhotoContractCard(
        photoContract: () => PhotoContract('Sample Album Title'),
        modifier: Modifier(),
      ),
    ),
  ));
}

class Modifier {
  // Custom modifier class to simulate Compose's Modifier
}
