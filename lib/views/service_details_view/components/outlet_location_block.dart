import 'dart:io';

import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/services/theme_service.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../helper/image_assets.dart';
import '../../../helper/local_keys.g.dart';
import '../../../services/google_location_search_service.dart';
import '../../../utils/components/custom_future_widget.dart';
import '../../../view_models/map_location_vew_model/map_single_location_view_model.dart';

class OutletLocationBlock extends StatelessWidget {
  const OutletLocationBlock({
    super.key,
    this.lat,
    this.lng,
    required this.title,
  });
  final lat;
  final lng;
  final String title;

  @override
  Widget build(BuildContext context) {
    final darkTheme =
        Provider.of<ThemeService>(context, listen: false).darkTheme;
    final msl = MapSingleLocationViewModel.instance;
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        SquircleContainer(
            height: 200,
            width: double.infinity,
            child:
                Consumer<GoogleLocationSearch>(builder: (context, gl, child) {
              return CustomFutureWidget(
                shimmer: SizedBox(
                  width: double.infinity,
                  child:
                      (darkTheme ? ImageAssets.mapDark : ImageAssets.mapLight)
                          .toAImage(fit: BoxFit.fitWidth),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ValueListenableBuilder(
                      valueListenable: msl.mark,
                      builder: (context, value, child) {
                        return GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(lat, lng),
                            zoom: 16.0,
                          ),
                          zoomControlsEnabled: false,
                          onMapCreated: (controller) async {
                            msl.controller = controller;
                            if (lat == null || lng == null) return;
                            final markerId = MarkerId("$lat$lng");
                            final latLng = LatLng(lat, lng);
                            final markerIcon = await BitmapDescriptor.asset(
                                const ImageConfiguration(),
                                "assets/images/marker.png");
                            msl.markers.putIfAbsent(
                                markerId,
                                () => Marker(
                                      markerId: markerId,
                                      position: latLng,
                                      icon: markerIcon,
                                    ));
                            msl.mark.value = msl.markers;
                          },
                          style: gl.dark,
                          buildingsEnabled: false,
                          mapToolbarEnabled: true,
                          indoorViewEnabled: false,
                          liteModeEnabled: true,
                          rotateGesturesEnabled: false,
                          myLocationButtonEnabled: false,
                          myLocationEnabled: false,
                          onCameraMove: (details) {},
                          mapType: MapType.normal,
                          markers: Set<Marker>.of(value.values),
                        );
                      }),
                ),
              );
            })),
        if (Platform.isIOS)
          IconButton(
            icon: Icon(Icons.directions, color: primaryColor, size: 36),
            onPressed: () async {
              LocalKeys.openingMap.showToast();
              debugPrint("opening apple map".toString());
              final url = 'http://maps.apple.com/?ll=$lat,$lng&q=$title';

              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              } else {
                throw 'Could not open Apple Maps';
              }
            },
          ),
      ],
    );
  }

  _getCurrentLoc(GoogleLocationSearch gl, {bool isDark = false}) async {
    final GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;
    await geolocatorPlatform.requestPermission();
    if (isDark && gl.dark == null) {
      await gl.setDark();
    }
  }
}
