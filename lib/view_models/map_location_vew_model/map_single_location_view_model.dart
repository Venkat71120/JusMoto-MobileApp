import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSingleLocationViewModel {
  final Map<MarkerId, Marker> markers = {};
  ValueNotifier<Map<MarkerId, Marker>> mark = ValueNotifier({});
  GoogleMapController? controller;

  MapSingleLocationViewModel._init();
  static MapSingleLocationViewModel? _instance;
  static MapSingleLocationViewModel get instance {
    _instance ??= MapSingleLocationViewModel._init();
    return _instance!;
  }

  MapSingleLocationViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }
}
