import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MarkerGenerator {
  final Function(List<Uint8List>) callback;
  final List<Widget> markerWidgets;

  MarkerGenerator(this.markerWidgets, this.callback);

  void generate(BuildContext context) {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => afterFirstLayout(context));
  }

  void afterFirstLayout(BuildContext context) {
    addOverlay(context);
  }

  void addOverlay(BuildContext context) {
    OverlayState overlayState = Overlay.of(context);

    OverlayEntry entry = OverlayEntry(
        builder: (context) {
          return _MarkerHelper(
            markerWidgets: markerWidgets,
            callback: callback,
          );
        },
        maintainState: true);

    overlayState.insert(entry);
  }
}

/// 맵은 Android/iOS에서 GoogleMap 라이브러리를 플러터에 임베딩합니다.
///
/// 이 네이티브 라이브러리들은 마커에 대해 BitmapDescriptor를 허용합니다.
/// 즉, 커스텀 마커의 경우 뷰를 비트맵으로 그린 후 이를 BitmapDescriptor로 보내야 합니다.
///
/// 이러한 이유로 Flutter도 마커에 위젯을 직접 받아들이지 못하고,
/// 대신 그것을 비트맵으로 변환해야 합니다.
/// 이 위젯이 수행하는 작업은 다음과 같습니다:
///
/// 1) 마커 위젯을 트리에 그립니다.
/// 2) 그려진 후 글로벌 키를 사용해 리페인트 경계에 접근하고 이를 Uint8List로 변환합니다.
/// 3) Uint8List (비트맵) 세트를 콜백을 통해 반환합니다.

class _MarkerHelper extends StatefulWidget {
  final List<Widget> markerWidgets;
  final Function(List<Uint8List>) callback;

  const _MarkerHelper({super.key, required this.markerWidgets, required this.callback});

  @override
  _MarkerHelperState createState() => _MarkerHelperState();
}

class _MarkerHelperState extends State<_MarkerHelper> with AfterLayoutMixin {
  List<GlobalKey> globalKeys = [];

  @override
  void afterFirstLayout(BuildContext context) {
    _getBitmaps(context).then((list) {
      widget.callback(list);
    });
  }

  @override
  Widget build(BuildContext context) {
    globalKeys.clear();  // 중복 추가 방지를 위해 초기화

    return Transform.translate(
      offset: Offset(MediaQuery.of(context).size.width, 0),
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: widget.markerWidgets.map((widget) {
            final markerKey = GlobalKey();
            globalKeys.add(markerKey);
            return RepaintBoundary(
              key: markerKey,
              child: widget,
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<List<Uint8List>> _getBitmaps(BuildContext context) async {
    var futures = globalKeys.map((key) => _getUint8List(key));
    return Future.wait(futures);
  }

  Future<Uint8List> _getUint8List(GlobalKey markerKey) async {
    RenderObject? boundary = markerKey.currentContext?.findRenderObject();

    if (boundary is! RenderRepaintBoundary) {
      throw Exception('RenderObject가 RepaintBoundary가 아닙니다');
    }

    var image = await boundary.toImage(pixelRatio: 2.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('이미지를 ByteData로 변환하는 데 실패했습니다');
    }

    return byteData.buffer.asUint8List();
  }
}

extension RenderObjectExtension on RenderObject? {
  Future<ui.Image> toImage({required double pixelRatio}) async {
    if (this is! RenderRepaintBoundary) {
      throw Exception('RenderObject가 RepaintBoundary가 아닙니다');
    }
    final boundary = this as RenderRepaintBoundary;
    return boundary.toImage(pixelRatio: pixelRatio);
  }
}

/// AfterLayoutMixin
mixin AfterLayoutMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => afterFirstLayout(context));
  }

  void afterFirstLayout(BuildContext context);
}
