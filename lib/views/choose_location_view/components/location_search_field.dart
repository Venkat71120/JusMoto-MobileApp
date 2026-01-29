import 'dart:async';

import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/view_models/location_search_view_model/location_search_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../helper/local_keys.g.dart';
import '../../../helper/svg_assets.dart';
import '../../../services/google_location_search_service.dart';
import '../../../utils/components/custom_squircle_widget.dart';

class LocationSearchField extends StatelessWidget {
  final GoogleMapController? googleMapController;
  const LocationSearchField({super.key, required this.googleMapController});

  @override
  Widget build(BuildContext context) {
    final lvm = LocationViewModel.instance;
    return Consumer<GoogleLocationSearch>(builder: (context, gl, child) {
      return Padding(
        padding: 24.paddingAll,
        child: SquircleContainer(
          color: context.color.cardFillColor,
          radius: 10,
          child: Autocomplete<String>(
            optionsBuilder: (tValue) async {
              debugPrint("option builder".toString());
              lvm.timer = Timer(1.seconds, () {
                lvm.locationSearchLoading.value = true;
                gl.fetchLocations(location: tValue.text).then((v) {
                  lvm.locationSearchLoading.value = false;
                });
              });
              print(gl.locations
                  .map((e) => e.description?.toString() ?? "")
                  .toList());
              final locDreascriptions = gl.locations
                  .map((e) => e.description?.toString() ?? "")
                  .toList();
              return locDreascriptions.isEmpty ? [""] : locDreascriptions;
            },
            onSelected: (value) {
              context.unFocus;
            },
            fieldViewBuilder:
                (context, textEditingController, focusNode, onFieldSubmitted) {
              return TextFormField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: InputDecoration(
                    hintText: LocalKeys.searchLocation,
                    fillColor: context.color.accentContrastColor,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SvgAssets.search.toSVGSized(
                        24,
                        color: context.color.secondaryContrastColor,
                      ),
                    )),
                onChanged: (value) {},
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              print(gl.locations.length);

              return SingleChildScrollView(
                child: Wrap(
                  runSpacing: 8,
                  children: gl.locations.map((loc) {
                    return Container(
                      color: context.color.accentContrastColor,
                      child: ListTile(
                        tileColor: context.color.cardFillColor,
                        leading: SvgAssets.currentLocation.toSVGSized(
                          24,
                          color: context.color.secondaryContrastColor,
                        ),
                        title: Text(loc.description ?? "--"),
                        onTap: () async {
                          gl
                              .fetchPlaceDetails(loc.placeId)
                              .then((result) async {
                            if (result?.result?.geometry?.location?.lat ==
                                    null ||
                                result?.result?.geometry?.location?.lng ==
                                    null) {
                              return;
                            }
                            await googleMapController
                                ?.animateCamera(CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                    result!.result!.geometry!.location!.lat!,
                                    result.result!.geometry!.location!.lng!),
                                zoom: 16,
                              ),
                            ));
                          });
                          context.unFocus;
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
