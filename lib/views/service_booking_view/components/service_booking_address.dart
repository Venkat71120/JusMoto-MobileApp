import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/models/google_places_model.dart';
import 'package:car_service/views/choose_location_view/choose_location_view.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../helper/local_keys.g.dart';
import '../../../helper/svg_assets.dart';
import '../../../utils/components/custom_squircle_widget.dart';
import '../../../utils/components/field_label.dart';
import '../../../view_models/service_booking_view_model/service_booking_view_model.dart';
import '../../service_booking_views/components/address_select_sheet.dart';

class ServiceBookingAddress extends StatelessWidget {
  const ServiceBookingAddress({super.key});

  @override
  Widget build(BuildContext context) {
    final svm = ServiceBookingViewModel.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(
          label: LocalKeys.address,
          isRequired: true,
        ),
        SquircleContainer(
          radius: 8,
          color: context.color.mutedContrastColor,
          child: TextFormField(
            controller: svm.addressController,
            minLines: 3,
            maxLines: 6,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: LocalKeys.enterAddress,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              prefixIcon: Column(
                children: [
                  SvgAssets.mapPin.toSVGSized(24,
                      color: context.color.tertiaryContrastColo),
                ],
              ),
            ),
            onTapOutside: (event) {
              context.unFocus;
            },
          ),
        ),
        8.toHeight,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                context.toPage(ChooseLocationView(), then: (result) {
                  if (result == null) return;
                  final prediction = (result as List).firstOrNull;

                  if (prediction == null) return;
                  svm.addressController.text =
                      (prediction! as Prediction).description ?? "";
                  debugPrint(prediction.description.toString());
                  if (prediction.lat != null && prediction.lng != null) {
                    svm.selectedLatLng.value =
                        LatLng(prediction.lat!, prediction.lng!);
                  }
                });
              },
              child: Text(
                LocalKeys.choseFromMap,
                style: context.titleSmall?.bold.copyWith(
                  color: primaryColor,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: context.color.accentContrastColor,
                  builder: (context) {
                    return AddressSelectSheet(
                        selectedAddress: svm.selectedAddress);
                  },
                );
              },
              child: Text(
                LocalKeys.selectAddress,
                style: context.titleSmall?.bold.copyWith(
                  color: primaryColor,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
