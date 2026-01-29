import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../helper/image_assets.dart';
import '../../models/home_models/services_list_model.dart';
import '../../services/theme_service.dart';

class ServiceListMapView extends StatelessWidget {
  final List<ServiceModel> serviceList;
  ServiceListMapView({super.key, required this.serviceList});

  LatLng? firstLocation;
  ValueNotifier<Map<MarkerId, Marker>> mark = ValueNotifier({});
  final Map<MarkerId, Marker> _markers = {};
  Map<MarkerId, Marker> get markers => _markers;
  final jobsLatLng = {};

  Future<void> getMarkers(BuildContext context) async {
    final markerIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(),
      "assets/images/marker.png",
    );
    debugPrint("Markers length is- ${markers.length}".toString());
  }

  @override
  Widget build(BuildContext context) {
    final darkTheme =
        Provider.of<ThemeService>(context, listen: false).darkTheme;
    return Scaffold(
      appBar: AppBar(leading: NavigationPopIcon()),
      body: CustomFutureWidget(
        function: getMarkers(context),
        shimmer: SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.cover,
            child: (darkTheme ? ImageAssets.mapDark : ImageAssets.mapLight)
                .toAImage(fit: BoxFit.fitWidth),
          ),
        ),
        child: ValueListenableBuilder(
          valueListenable: mark,
          builder: (context, value, child) {
            debugPrint(value.toString());
            debugPrint(Set<Marker>.of(value.values).length.toString());
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target:
                    firstLocation ??
                    const LatLng(23.75617346773963, 90.441897487471404),
                zoom: 13.0,
              ),
              zoomControlsEnabled: false,
              onMapCreated: (controller) {},
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
    );
  }
}
