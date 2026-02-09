import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/text_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../helper/local_keys.g.dart';
import '../../../helper/svg_assets.dart';
import '../../../services/google_location_search_service.dart';
import '../../../utils/components/custom_button.dart';
import '../../../view_models/add_edit_address_view_model/add_edit_address_view_model.dart';

class ChooseLocationButtons extends StatelessWidget {
  const ChooseLocationButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GoogleLocationSearch>(
      builder: (context, gl, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
              color: context.color.accentContrastColor,
              border: Border(
                  top: BorderSide(color: context.color.primaryBorderColor))),
          child: Column(
            children: [
              SquircleContainer(
                radius: 10,
                color: context.color.mutedContrastColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    SvgAssets.mapPin.toSVGSized(
                      24,
                      color: context.color.secondaryContrastColor,
                    ),
                    12.toWidth,
                    Expanded(
                        flex: 1,
                        child: gl.isLoading
                            ? TextSkeleton(
                                height: 14,
                                width: context.width / 1.5,
                                color: context.color.primaryBorderColor,
                              ).shim
                            : Text(
                                gl.geoLoc?.description ??
                                    LocalKeys.selectALocationByMovingMap,
                                style: context.titleSmall?.bold6,
                              ))
                  ],
                ),
              ),
              12.toHeight,
              CustomButton(
                  onPressed: gl.geoLoc == null ? null : () {
                    final aea = AddEditAddressViewModel.instance;
                    
                    // Set the address text
                    aea.addressController.text = gl.geoLoc?.description ?? "";
                    
                    // Mark that address was selected from map
                    aea.selectedFromMap.value = true;
                    
                    // Return the location data with coordinates
                    Navigator.pop(context, [gl.geoLoc]);
                  },
                  btText: LocalKeys.useThisLocation),
            ],
          ),
        );
      },
    );
  }
}