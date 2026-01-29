import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/field_label.dart';
import 'package:car_service/view_models/landding_view_model/landding_view_model.dart';
import 'package:car_service/view_models/select_car_view_model/select_car_view_model.dart';
import 'package:car_service/views/select_car_view/select_car_view.dart';
import 'package:flutter/material.dart';

import 'components/car_fuel_card.dart';

class MyCarView extends StatelessWidget {
  const MyCarView({super.key});

  @override
  Widget build(BuildContext context) {
    final lm = LandingViewModel.instance;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(LocalKeys.myCar),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SquircleContainer(
              radius: 12,
              padding: 12.paddingAll,
              color: context.color.accentContrastColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed: () {
                            SelectCarViewModel.dispose;
                            context.toPage(SelectCarView());
                          },
                          child: Text(LocalKeys.changeCar)),
                      IconButton(
                          onPressed: () {
                            SelectCarViewModel.dispose;
                            context.toPage(SelectCarView());
                          },
                          icon: SvgAssets.edit
                              .toSVGSized(24, color: primaryColor)),
                    ],
                  ),
                  12.toHeight,
                  Center(
                    child: CustomNetworkImage(
                      imageUrl: lm.selectedCar.value?.image,
                      width: context.width * 0.5,
                      height: context.width * 0.3,
                      fit: BoxFit.contain,
                      carPlaceholder: true,
                    ),
                  ),
                  8.toHeight,
                  Center(
                    child: Text(
                      lm.selectedCar.value?.name ?? "---",
                      style: context.titleMedium?.bold,
                    ),
                  ),
                ],
              ),
            ),
            16.toHeight,
            SquircleContainer(
              radius: 12,
              width: double.infinity,
              padding: 12.paddingAll,
              color: context.color.accentContrastColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FieldLabel(label: LocalKeys.carTransmissionType),
                  RadioListTile(
                    dense: true,
                    value: true,
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    groupValue: true,
                    onChanged: (value) {},
                    title: Text(
                      lm.selectedCar.value?.variants.firstOrNull?.engineType
                              ?.name ??
                          "---",
                      style: context.titleSmall,
                    ),
                  ),
                ],
              ),
            ),
            16.toHeight,
            FieldLabel(label: LocalKeys.carFuelType),
            8.toHeight,
            CarFuelCard(
              name:
                  lm.selectedCar.value?.variants.firstOrNull?.fuelType?.name ??
                      "---",
              icon:
                  lm.selectedCar.value?.variants.firstOrNull?.fuelType?.image ??
                      "---",
              isSelected: true,
            ),
          ],
        ),
      ),
    );
  }
}
