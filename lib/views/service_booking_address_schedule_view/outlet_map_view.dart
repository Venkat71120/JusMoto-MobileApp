import 'dart:async';

import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/services/outlet_service.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/view_models/service_booking_view_model/service_booking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:provider/provider.dart';

import '../../helper/local_keys.g.dart';
import '../../helper/svg_assets.dart';
import '../../models/outlet_model.dart';
import '../../services/theme_service.dart';
import '../../customizations/colors.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/custom_squircle_widget.dart';

class OutletMapView extends StatelessWidget {
  final OutletService os;
  OutletMapView({super.key, required this.os});

  LatLng? firstLocation;
  GoogleMapController? mapController;
  ValueNotifier<Map<MarkerId, Marker>> mark = ValueNotifier({});
  final Map<MarkerId, Marker> _markers = {};
  Map<MarkerId, Marker> get markers => _markers;
  final jobsLatLng = {};

  Future<void> getMarkers(BuildContext context) async {
    if (os.shouldAutoFetch) {
      await os.fetchOutlets();
    }
    final markerIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(), "assets/images/marker.png");

    for (Outlet e in os.outletList) {
      if (e.latitude == null || e.longitude == null) {
        continue;
      }
      final markerId = MarkerId(e.id.toString());
      final latLng = LatLng(e.latitude!, e.longitude!);
      _markers.putIfAbsent(
          markerId,
          () => Marker(
                markerId: markerId,
                position: latLng,
                icon: markerIcon,
                onTap: () {
                  showAdaptiveDialog(
                    context: context,
                    anchorPoint: Offset(context.height / 2, context.width / 2),
                    barrierColor: Colors.transparent,
                    builder: (context) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            bottom: (context.height / 2.3) + 70,
                            child: Material(
                              color: Colors.transparent,
                              child: GestureDetector(
                                onTap: () {
                                  ServiceBookingViewModel
                                      .instance.selectedOutlet.value = e;
                                  Navigator.pop(context); // Close dialog
                                  Navigator.pop(context); // Go back to booking page
                                },
                                child: SquircleContainer(
                                  radius: 12,
                                  color: context.color.accentContrastColor,
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.outletName ?? "--",
                                        style: context.titleSmall?.bold,
                                      ),
                                      if (e.address != null) ...[
                                        4.toHeight,
                                        SizedBox(
                                          width: 200,
                                          child: Text(
                                            e.address!,
                                            style: context.bodySmall,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                      8.toHeight,
                                      Text(
                                        "Click to Select",
                                        style: context.labelSmall?.copyWith(
                                            color: primaryColor),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ));
      firstLocation ??= latLng;
      mark.value = Map.from(_markers);
      await Future.delayed(50.milliseconds);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: NavigationPopIcon(),
      ),
      body: CustomFutureWidget(
        function: getMarkers(context),
        shimmer: SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SvgPicture.asset(
              "assets/svg/${Provider.of<ThemeService>(context, listen: false).darkTheme ? "map_dark" : "map_light"}.svg",
            ),
          ),
        ),
        child: ValueListenableBuilder(
          valueListenable: mark,
          builder: (context, value, child) {
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: firstLocation ??
                    const LatLng(23.75617346773963, 90.441897487471404),
                zoom: 10.0,
              ),
              zoomControlsEnabled: false,
              onMapCreated: (controller) {
                mapController = controller;
              },
              markers: Set<Marker>.of(value.values),
              buildingsEnabled: false,
              mapToolbarEnabled: true,
              indoorViewEnabled: false,
              liteModeEnabled: false,
              rotateGesturesEnabled: false,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              mapType: MapType.normal,
            );
          },
        ),
      ),
      floatingActionButton: IconButton(
          style: ButtonStyle(
              backgroundColor: WidgetStateColor.resolveWith(
            (states) => context.color.accentContrastColor,
          )),
          onPressed: () {
            final ScrollController controller = ScrollController();
            Timer? scheduleTimeout;

            Provider.of<OutletService>(context, listen: false).resetList();
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    color: context.color.accentContrastColor,
                  ),
                  constraints: BoxConstraints(
                      maxHeight: context.height / 2 +
                          (MediaQuery.of(context).viewInsets.bottom / 2)),
                  child: Consumer<OutletService>(
                      builder: (context, cProvider, child) {
                    return Column(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 4,
                            width: 48,
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: context.color.primaryBorderColor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: TextFormField(
                              decoration: InputDecoration(
                                  hintText: LocalKeys.searchOutlet,
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: SvgAssets.search.toSVGSized(24,
                                        color: context
                                            .color.secondaryContrastColor),
                                  )),
                              onChanged: (value) {
                                scheduleTimeout?.cancel();
                                scheduleTimeout =
                                    Timer(const Duration(seconds: 1), () {
                                  cProvider.setOutletSearchValue(value);
                                });
                              }),
                        ),
                        Expanded(
                          child: ListView.separated(
                              controller: controller,
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(
                                  right: 20, left: 20, bottom: 20),
                              itemBuilder: (context, index) {
                                if (cProvider.outletLoading ||
                                    (cProvider.outletList.length == index &&
                                        cProvider.nextPage != null)) {
                                  return const SizedBox(
                                      height: 50,
                                      width: double.infinity,
                                      child: Center(child: CustomPreloader()));
                                }
                                if (cProvider.outletList.isEmpty) {
                                  return SizedBox(
                                    width: context.width - 60,
                                    child: Center(
                                      child: Text(
                                        LocalKeys.noResultFound,
                                        style: context.titleSmall,
                                      ),
                                    ),
                                  );
                                }
                                if (cProvider.outletList.length == index) {
                                  return const SizedBox();
                                }
                                final element = cProvider.outletList[index];
                                return InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    mapController?.animateCamera(
                                        CameraUpdateNewLatLng(LatLng(
                                            element.latitude!,
                                            element.longitude!)));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 14),
                                    child: Text(
                                      element.outletName ?? "",
                                      style: context.titleSmall,
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                    height: 8,
                                    child: Center(child: Divider()),
                                  ),
                              itemCount: cProvider.outletLoading == true ||
                                      cProvider.outletList.isEmpty
                                  ? 1
                                  : cProvider.outletList.length +
                                      (cProvider.nextPage != null &&
                                              !cProvider.nexLoadingFailed
                                          ? 1
                                          : 0)),
                        )
                      ],
                    );
                  }),
                );
              },
            );
          },
          icon: Icon(
            Icons.list_rounded,
            color: context.color.secondaryContrastColor,
          )),
    );
  }
}
