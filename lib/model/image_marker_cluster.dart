import 'dart:typed_data';

import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test2/model/memberImg.dart';

class ImageMarkerCluster with ClusterItem {
  final LatLng position;
  final String name;
  final String img_data;

  ImageMarkerCluster({required this.position, required this.name, required this.img_data});

  @override
  LatLng get location => position;

  Uint8List get imgUint => BytesToImage(img_data);
}