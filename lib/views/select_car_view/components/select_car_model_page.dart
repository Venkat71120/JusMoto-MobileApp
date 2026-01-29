import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/car_services/model_list_service.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/view_models/select_car_view_model/select_car_view_model.dart';
import 'package:car_service/views/select_car_view/components/car_model_card.dart';
import 'package:car_service/views/select_car_view/components/car_model_grid_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../helper/image_assets.dart';

class SelectCarModelPage extends StatelessWidget {
  const SelectCarModelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scm = SelectCarViewModel.instance;
    return Consumer<ModelListService>(builder: (context, mls, child) {
      return CustomRefreshIndicator(
        onRefresh: () async {
          await mls.fetchCarModelList(bId: scm.selectedBrand.value?.id);
        },
        child: CustomFutureWidget(
          function: mls.shouldAutoFetch(bId: scm.selectedBrand.value?.id)
              ? mls.fetchCarModelList(bId: scm.selectedBrand.value?.id)
              : null,
          shimmer: CarModelGridSkeleton(),
          child: Scrollbar(
            controller: scm.scrollController,
            child: mls.carModelsModel.allCarModels?.isEmpty ?? true
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: context.width * .9,
                          height: context.width * .5,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            image: ImageAssets.carPlaceholder.toAsset,
                            opacity: .3,
                            fit: BoxFit.fitWidth,
                          ))),
                      20.toHeight,
                      Text(
                        LocalKeys.noCarModelAvailable,
                        style: context.titleMedium,
                      )
                    ],
                  )
                : SingleChildScrollView(
                    controller: scm.scrollController,
                    padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 20, vertical: 8),
                    physics: AlwaysScrollableScrollPhysics(),
                    child: ValueListenableBuilder(
                        valueListenable: scm.selectedCar,
                        builder: (context, value, child) {
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: mls.carModelsModel.allCarModels!.map(
                              (car) {
                                return GestureDetector(
                                  onTap: () {
                                    scm.selectedCar.value = car;
                                  },
                                  child: CarModelCard(
                                    name: car.name ?? "--",
                                    imageUrl: car.image ?? "",
                                    isSelected: value?.name?.toString() ==
                                        car.name.toString(),
                                  ),
                                );
                              },
                            ).toList(),
                          );
                        }),
                  ),
          ),
        ),
      );
    });
  }
}
