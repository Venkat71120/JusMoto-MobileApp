import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/models/car_models/car_model_list_model.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/field_label.dart';
import '../../../utils/components/field_with_label.dart';
import 'package:car_service/view_models/select_car_view_model/select_car_view_model.dart';
import 'package:car_service/customizations/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../my_car_view/components/car_fuel_card.dart';
import '../../../services/car_services/variant_list_service.dart';
import '../../../utils/components/custom_future_widget.dart';

class SelectCarDetailsPage extends StatelessWidget {
  const SelectCarDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scm = SelectCarViewModel.instance;
    return Consumer<VariantListService>(
      builder: (context, vls, child) {
        return CustomRefreshIndicator(
          onRefresh: () async {
            await vls.fetchVariantList(cId: scm.selectedCar.value?.id);
          },
          child: CustomFutureWidget(
            function:
                vls.shouldAutoFetch(cId: scm.selectedCar.value?.id)
                    ? vls.fetchVariantList(cId: scm.selectedCar.value?.id)
                    : null,
            shimmer: Center(
              child: CircularProgressIndicator(),
            ), // Need a skeleton
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  SquircleContainer(
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
                              Center(
                                child: CustomNetworkImage(
                                  imageUrl: scm.selectedCar.value?.image,
                                  width: context.width * 0.5,
                                  height: context.width * 0.3,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              8.toHeight,
                              Center(
                                child: Text(
                                  scm.selectedCar.value?.name ?? "---",
                                  style: context.titleMedium?.bold,
                                ),
                              ),
                              if (scm.isEditing) ...[
                                4.toHeight,
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      // Force navigate backward to Model Selection
                                      scm.goBack(context, forceSteps: true);
                                    },
                                    child: Text(
                                      "Change Car Model",
                                      style: context.labelMedium?.copyWith(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                        decorationColor: primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        16.toHeight,
                        ValueListenableBuilder(
                          valueListenable: scm.selectedVariant,
                          builder: (context, value, child) {
                            return SquircleContainer(
                              radius: 12,
                              width: double.infinity,
                              padding: 12.paddingAll,
                              color: context.color.accentContrastColor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if ((vls.variantListModel.allVariants ?? []).isNotEmpty) ...[
                                    FieldLabel(label: "Variants"),
                                    Wrap(
                                      children:
                                          (vls.variantListModel.allVariants ?? [])
                                              .map((e) {
                                                return SizedBox(
                                                  width:
                                                      ((context.width - 100) /
                                                                  2) <
                                                              100
                                                          ? null
                                                          : (context.width -
                                                                  100) /
                                                              2,
                                                  child: RadioListTile(
                                                    dense: true,
                                                    value: value?.id == e.id,
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    groupValue: true,
                                                    onChanged: (val) {
                                                      scm.selectedVariant.value =
                                                          e;
                                                    },
                                                    title: Text(
                                                      "${e.name ?? ''}\n${e.engineType?.name ?? ''} | ${e.fuelType?.name ?? ''}",
                                                      style: context.titleSmall,
                                                    ),
                                                  ),
                                                );
                                              })
                                              .toList(),
                                    ),
                                    16.toHeight,
                                  ],
                                  FieldWithLabel(
                                    label: "Registration Number (Optional)",
                                    hintText: "Enter registration number",
                                    controller: scm.regNoController,
                                    textCapitalization: TextCapitalization.characters,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
