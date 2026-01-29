import 'dart:async';

import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/image_assets.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/views/choose_location_view/components/location_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../helper/svg_assets.dart';
import '../../services/google_location_search_service.dart';
import '../../utils/components/custom_future_widget.dart';
import '../../view_models/add_edit_address_view_model/add_edit_address_view_model.dart';
import 'components/choose_location_buttons.dart';

class ChooseLocationView extends StatelessWidget {
  ChooseLocationView({super.key});
  GoogleMapController? controller;
  ValueNotifier<Position?> currentLoc = ValueNotifier(null);
  String? dark;

  @override
  Widget build(BuildContext context) {
    final aea = AddEditAddressViewModel.instance;

    Timer? timer;
    return Consumer<GoogleLocationSearch>(builder: (context, gl, child) {
      return Scaffold(
          appBar: AppBar(
            leading: const NavigationPopIcon(),
            title: Text(
              LocalKeys.choseLocation,
            ),
          ),
          body: Hero(
            tag: "map",
            child: CustomFutureWidget(
              function:
                  gl.isLoading || gl.geoLoc != null || currentLoc.value != null
                      ? null
                      : _getCurrentLoc(gl: gl),
              shimmer: SizedBox(
                width: double.infinity,
                child: ImageAssets.mapLight.toAImage(fit: BoxFit.fitWidth).shim,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                                gl.geoLoc?.lat ??
                                    currentLoc.value?.latitude ??
                                    23.75617346773963,
                                gl.geoLoc?.lng ??
                                    currentLoc.value?.longitude ??
                                    90.441897487471404),
                            zoom: 16.0,
                          ),
                          zoomControlsEnabled: false,
                          onMapCreated: (controller) {
                            this.controller = controller;
                          },
                          style: dark,
                          buildingsEnabled: false,
                          mapToolbarEnabled: true,
                          indoorViewEnabled: false,
                          liteModeEnabled: false,
                          rotateGesturesEnabled: false,
                          myLocationButtonEnabled: true,
                          myLocationEnabled: true,
                          onCameraMove: (details) {
                            timer?.cancel();
                            timer = Timer(
                              1.seconds,
                              () {
                                gl.fetchGEOLocations(
                                  lat: details.target.latitude,
                                  lng: details.target.longitude,
                                );
                              },
                            );
                            aea.controller
                                ?.animateCamera(CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target:
                                    LatLng(gl.geoLoc!.lat!, gl.geoLoc!.lng!),
                                zoom: 16,
                              ),
                            ));
                          },
                          mapType: MapType.normal,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 48),
                            child: SvgAssets.mapLongPin.toSVGSized(62),
                          ),
                        ),
                        LocationSearchField(googleMapController: controller),
                      ],
                    ),
                  ),
                  const ChooseLocationButtons(),
                ],
              ),
            ),
          ));
    });
  }

  _getCurrentLoc({gl}) async {
    final GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;
    await geolocatorPlatform.requestPermission();
    currentLoc.value = await geolocatorPlatform.getCurrentPosition();
    if (gl.dark == true) {
      await gl.setDark();
    }
  }
}
