import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/models/outlet_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

import '../../../customizations/colors.dart';
import '../../../helper/local_keys.g.dart';
import '../../../helper/svg_assets.dart';

class OrderDetailsOutlet extends StatelessWidget {
  final Outlet outlet;
  const OrderDetailsOutlet({super.key, required this.outlet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgAssets.mapPin.toSVGSized(20, color: primaryColor),
          8.toWidth,
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocalKeys.outlet,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.titleSmall?.bold,
                ),
                6.toHeight,
                Text(
                  outlet.address ?? "---",
                  style: context.bodySmall,
                ),
              ],
            ),
          ),
          8.toWidth,
          if (outlet.latitude != null && outlet.longitude != null)
            GestureDetector(
              onTap: () async {
                String googleUrl =
                    'https://www.google.com/maps/search/?api=1&query=${outlet.latitude},${outlet.longitude}';
                if (await urlLauncher.canLaunch(googleUrl)) {
                  await urlLauncher.launch(googleUrl);
                } else {
                  throw 'Could not open the map.';
                }
              },
              child: Container(
                padding: 10.paddingAll,
                child: SvgAssets.location.toSVGSized(20, color: primaryColor),
              ),
            ),
        ],
      ),
    );
  }
}
