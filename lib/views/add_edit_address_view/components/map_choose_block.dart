import 'dart:async';

import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/services/theme_service.dart';
import 'package:car_service/utils/components/custom_preloader.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../helper/image_assets.dart';
import '../../../helper/svg_assets.dart';
import '../../../services/google_location_search_service.dart';
import '../../../utils/components/custom_future_widget.dart';
import '../../../view_models/add_edit_address_view_model/add_edit_address_view_model.dart';
import '../../choose_location_view/choose_location_view.dart';

class MapChooseBlock extends StatelessWidget {
  MapChooseBlock({super.key});
  GoogleMapController? controller;
  ValueNotifier<Position?> currentLoc = ValueNotifier(null);

  // Helper method to populate fields from geoLoc
  void _populateAddressFields(GoogleLocationSearch gl) {
    final aea = AddEditAddressViewModel.instance;
    
    // Populate address field
    if (gl.geoLoc?.description != null && gl.geoLoc!.description!.isNotEmpty) {
      aea.addressController.text = gl.geoLoc!.description!;
      debugPrint("✅ Address field populated: ${gl.geoLoc!.description}");
    }
    
    // Populate zip code field
    if (gl.geoLoc?.postCode != null && gl.geoLoc!.postCode!.isNotEmpty) {
      aea.zipCodeController.text = gl.geoLoc!.postCode!;
      debugPrint("✅ Zip code field populated: ${gl.geoLoc!.postCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    Timer? timer;
    final darkTheme =
        Provider.of<ThemeService>(context, listen: false).darkTheme;
    final aea = AddEditAddressViewModel.instance;
    return SquircleContainer(
        radius: 20,
        borderColor: context.color.primaryBorderColor,
        height: 300,
        width: double.infinity,
        child: Consumer<GoogleLocationSearch>(builder: (context, gl, child) {
          return GestureDetector(
            onTapDown: gl.isLoading
                ? null
                : (_) {
                    aea.disableScroll.value = true;
                  },
            onTapCancel: gl.isLoading
                ? null
                : () {
                    aea.disableScroll.value = false;
                  },
            child: CustomFutureWidget(
              function:
                  gl.isLoading || gl.geoLoc != null || currentLoc.value != null
                      ? null
                      : _getCurrentLoc(gl, isDark: darkTheme),
              shimmer: SizedBox(
                width: double.infinity,
                child: (darkTheme ? ImageAssets.mapDark : ImageAssets.mapLight)
                    .toAImage(fit: BoxFit.fitWidth),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: GoogleMap(
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
                        if (currentLoc.value != null) {
                          debugPrint("Current location is ----------------- ${currentLoc.value}");
                          controller.animateCamera(CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(
                                currentLoc.value!.latitude,
                                currentLoc.value!.longitude
                              ),
                              zoom: 16,
                            ),
                          ));
                          
                          // Fetch address for current location and populate fields
                          gl.fetchGEOLocations(
                            lat: currentLoc.value!.latitude,
                            lng: currentLoc.value!.longitude,
                          ).then((_) {
                            _populateAddressFields(gl);
                          });
                        }
                      },
                      style: gl.dark,
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
                          () async {
                            if (gl.geoLoc?.lat.toString() ==
                                    details.target.latitude.toString() &&
                                gl.geoLoc?.lng.toString() ==
                                    details.target.longitude.toString()) {
                              return;
                            }
                            await gl.fetchGEOLocations(
                              lat: details.target.latitude,
                              lng: details.target.longitude,
                            );
                            
                            // Populate both address and zip code fields
                            _populateAddressFields(gl);
                          },
                        );
                      },
                      mapType: MapType.normal,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.only(bottom: gl.isLoading ? 24 : 48),
                      child: gl.isLoading
                          ? const CustomPreloader()
                          : SvgAssets.mapLongPin.toSVGSized(62),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.toPage(ChooseLocationView());
                    },
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.fullscreen_rounded,
                          color: context.color.tertiaryContrastColo,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }));
  }

  _getCurrentLoc(GoogleLocationSearch gl, {bool isDark = false}) async {
    final GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;
    
    // Check permission status first
    LocationPermission permission = await geolocatorPlatform.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle denied permission
        debugPrint('Location permissions are denied');
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Handle permanently denied permission
      debugPrint('Location permissions are permanently denied');
      return;
    }
    
    currentLoc.value = await geolocatorPlatform.getCurrentPosition();
    
    // Fetch address for current location and populate fields
    if (currentLoc.value != null) {
      await gl.fetchGEOLocations(
        lat: currentLoc.value!.latitude,
        lng: currentLoc.value!.longitude,
      );
      
      // Populate both address and zip code fields
      _populateAddressFields(gl);
    }
    
    if (isDark && gl.dark == null) {
      await gl.setDark();
    }
  }
}