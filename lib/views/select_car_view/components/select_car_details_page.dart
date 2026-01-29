import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/models/car_models/car_model_list_model.dart';
import 'package:car_service/services/car_services/model_list_service.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/field_label.dart';
import 'package:car_service/view_models/select_car_view_model/select_car_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../my_car_view/components/car_fuel_card.dart';

class SelectCarDetailsPage extends StatelessWidget {
  const SelectCarDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scm = SelectCarViewModel.instance;
    final variants = scm.selectedCar.value?.variants ?? [];
    final uniqIds = variants.map((v) => v.engineType?.id).toSet().toList();
    final List<VariantTypes> engines = [];
    for (var element in uniqIds) {
      final vt =
          variants.firstWhere((el) => el.engineType?.id == element).engineType;
      if (vt == null) continue;
      engines.add(vt);
    }
    return CustomRefreshIndicator(
      onRefresh: () async {
        await Provider.of<ModelListService>(context, listen: false)
            .fetchCarModelList(bId: scm.selectedBrand.value?.id);
      },
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
                      ],
                    ),
                  ),
                  16.toHeight,
                  ValueListenableBuilder(
                      valueListenable: scm.selectedEngine,
                      builder: (context, value, child) {
                        return SquircleContainer(
                          radius: 12,
                          width: double.infinity,
                          padding: 12.paddingAll,
                          color: context.color.accentContrastColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FieldLabel(label: LocalKeys.carTransmissionType),
                              Wrap(
                                children: engines.map(
                                  (e) {
                                    return SizedBox(
                                      width: ((context.width - 100) / 2) < 100
                                          ? null
                                          : (context.width - 100) / 2,
                                      child: RadioListTile(
                                        dense: true,
                                        value: value == (e.id).toString(),
                                        contentPadding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                        groupValue: true,
                                        onChanged: (value) {
                                          scm.selectedEngine.value =
                                              e.id?.toString();
                                        },
                                        title: Text(
                                          e.name ?? "---",
                                          style: context.titleSmall,
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                            ],
                          ),
                        );
                      }),
                  16.toHeight,
                  FieldLabel(label: LocalKeys.carFuelType),
                  8.toHeight,
                  ValueListenableBuilder(
                      valueListenable: scm.selectedEngine,
                      builder: (context, e, child) {
                        final fuels = variants
                            .where(
                              (element) =>
                                  element.engineType?.id?.toString() ==
                                  e.toString(),
                            )
                            .map((f) => f.fuelType)
                            .toSet()
                            .toList();
                        if (!fuels.contains(scm.selectedFuel.value)) {
                          scm.selectedFuel.value =
                              fuels.firstOrNull?.id?.toString();
                        }
                        return ValueListenableBuilder(
                            valueListenable: scm.selectedFuel,
                            builder: (context, fuel, child) {
                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: fuels
                                    .map(
                                      (f) => GestureDetector(
                                        onTap: () {
                                          scm.selectedFuel.value =
                                              f?.id?.toString();
                                        },
                                        child: CarFuelCard(
                                          name: f?.name ?? "---",
                                          icon: f?.image ?? "---",
                                          isSelected:
                                              fuel == (f?.id).toString(),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              );
                            });
                      }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
