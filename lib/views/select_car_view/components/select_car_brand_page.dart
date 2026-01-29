import 'package:car_service/services/car_services/brand_list_service.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/view_models/select_car_view_model/select_car_view_model.dart';
import 'package:car_service/views/select_car_view/components/brand_grid_skeleton.dart';
import 'package:car_service/views/select_car_view/components/car_brand_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectCarBrandPage extends StatelessWidget {
  const SelectCarBrandPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scm = SelectCarViewModel.instance;
    return Consumer<BrandListService>(builder: (context, bs, child) {
      return CustomRefreshIndicator(
        onRefresh: () async {
          await bs.fetchBrandList();
        },
        child: CustomFutureWidget(
          function: bs.shouldAutoFetch ? bs.fetchBrandList() : null,
          shimmer: BrandGridSkeleton(),
          child: Scrollbar(
            controller: scm.scrollController,
            child: SingleChildScrollView(
              controller: scm.scrollController,
              padding:
                  EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 8),
              physics: AlwaysScrollableScrollPhysics(),
              child: ValueListenableBuilder(
                  valueListenable: scm.selectedBrand,
                  builder: (context, value, child) {
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: bs.myBrandsModel.allBrands!.map(
                        (brand) {
                          return GestureDetector(
                            onTap: () {
                              scm.selectedBrand.value = brand;
                            },
                            child: CarBrandCard(
                              name: brand.name ?? "--",
                              imageUrl: brand.image ?? "",
                              isSelected:
                                  value?.id?.toString() == brand.id.toString(),
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
