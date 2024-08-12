import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test2/model/image_marker_cluster.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:test2/model/picture.dart';
import 'package:test2/model/team.dart';

class GoogleMapCluster extends StatefulWidget {
  const GoogleMapCluster({super.key});

  @override
  _GoogleMapClusterState createState() => _GoogleMapClusterState();
}

class _GoogleMapClusterState extends State<GoogleMapCluster> {
  late ClusterManager<ImageMarkerCluster> _clusterManager;
  final Set<Marker> _markers = {};
  final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(36.2048, 127.7669),
    zoom: 7.0,
  );

  @override
  void initState() {
    super.initState();
    _initClusterManager();
  }

  void _initClusterManager() {
    _clusterManager = ClusterManager<ImageMarkerCluster>(
      [],
      _updateMarkers,
      markerBuilder: _markerBuilder,
      levels: [1, 4.25, 6.75, 8.25, 11.5, 14.5, 16.0, 16.5, 20.0],
      extraPercent: 0.2,
    );
    _loadImages();
  }

  void _updateMarkers(Set<Marker> markers) {
    setState(() {
      _markers.clear();
      _markers.addAll(markers);
    });
  }

  Future<Marker> Function(Cluster<ImageMarkerCluster>) get _markerBuilder => (cluster) async {
    return Marker(
      markerId: MarkerId(cluster.getId()),
      position: cluster.location,
      onTap: () {
        debugPrint('---- $cluster');
        cluster.items.forEach((p) => debugPrint(p.name));
      },
      icon: await _getMarkerBitmap(85,
          text: cluster.isMultiple ? cluster.count.toString() : null,
          image: cluster.items.isNotEmpty ? cluster.items.first.imgUint : null),
    );
  };

  Future<BitmapDescriptor> _getMarkerBitmap(int size,
      {String? text, Uint8List? image}) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint orangePaint = Paint()..color = Colors.orange;
    final Paint whitePaint = Paint()..color = Colors.white;

    // 테두리 두께 설정
    final double orangeBorderThickness = size * 0.03; // 3% of the size

    // 외부 네모 마커 그리기 (오렌지색 테두리)
    final double borderRadius = size / 12;
    final Rect outerRect = Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble());
    final RRect outerRRect = RRect.fromRectAndRadius(outerRect, Radius.circular(borderRadius));

    canvas.drawRRect(outerRRect, orangePaint);

    // 흰색 영역 그리기 (더 작게)
    final double whiteAreaInset = orangeBorderThickness + size * 0.03; // 오렌지 테두리 + 추가 5%
    final Rect whiteRect = Rect.fromLTWH(
        whiteAreaInset,
        whiteAreaInset,
        size - (2 * whiteAreaInset),
        size - (2 * whiteAreaInset)
    );
    final RRect whiteRRect = RRect.fromRectAndRadius(
        whiteRect,
        Radius.circular(borderRadius - whiteAreaInset)
    );

    canvas.drawRRect(whiteRRect, whitePaint);
    // 원 마커 그리기
    /*canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);*/

    if (image != null) {
      final ui.Codec codec = await ui.instantiateImageCodec(image);
      final ui.FrameInfo fi = await codec.getNextFrame();
      final imageSize = size * 0.8;
      canvas.drawImageRect(
        fi.image,
        Rect.fromLTRB(0, 0, fi.image.width.toDouble(), fi.image.height.toDouble()),
        Rect.fromLTWH((size - imageSize) / 2, (size - imageSize) / 2, imageSize, imageSize), //(size - imageSize) / 2, (size - imageSize) / 2,
        Paint(),
      );
    }

    if (text != null) {

      // 텍스트 그리기
      final fontSize = size / 3;
      final textStyle = TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      );

      // 외곽선 그리기
      final outlineStyle = TextStyle(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = Colors.black,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      );

      final textPainter = TextPainter(
        text: TextSpan(text: text, style: outlineStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size - textPainter.width - size * 0.1, size * 0.1),
      );

      textPainter.text = TextSpan(text: text, style: textStyle);
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size - textPainter.width - size * 0.1, size * 0.1),
      );
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(data!.buffer.asUint8List());
  }

  void _loadImages() async {
    final PicManager picManager = PicManager();
    final TeamManager teamManager = TeamManager();
    final String currentTeam = teamManager.currentTeam;
    final int? currentTeamNo = teamManager.getTeamNoByTeamName(currentTeam);

    if (currentTeamNo == null) {
      debugPrint('팀을 설정하세요');
      return;
    }

    final List<PictureEntity> pictures = picManager.getPictureList()
        .where((pic) => pic.team_num == currentTeamNo)
        .toList();

    pictures.sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending

    final List<ImageMarkerCluster> items = pictures.map((pic) => ImageMarkerCluster(
      position: LatLng(pic.latitude, pic.longitude),
      name: pic.img_num.toString(),
      img_data: pic.img_data,
    )).toList();

    _clusterManager.setItems(items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _clusterManager.setMapId(controller.mapId);
            },
            initialCameraPosition: _initialCameraPosition,
            markers: _markers,
            onCameraMove: _clusterManager.onCameraMove,
            onCameraIdle: _clusterManager.updateMap,
          ),
        ],
      ),
    );
  }
}