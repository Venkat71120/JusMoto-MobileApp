import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/models/car_models/brand_list_model.dart';
import 'package:car_service/services/car_services/brand_list_service.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:car_service/utils/components/field_label.dart';
import 'package:car_service/view_models/service_details_view_model/service_details_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ServiceDetailsBrandSelection extends StatelessWidget {
  const ServiceDetailsBrandSelection({super.key});

  @override
  Widget build(BuildContext context) {
    final sdm = ServiceDetailsViewModel.instance;
    final brandService = Provider.of<BrandListService>(context, listen: false);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.color.accentContrastColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FieldLabel(
              label: "Vehicle Brand",
              isRequired: true,
            ),
          ),
          CustomFutureWidget(
            function: brandService.shouldAutoFetch ? brandService.fetchBrandList() : null,
            shimmer: Container(
              height: 50,
              decoration: BoxDecoration(
                color: context.color.mutedContrastColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Consumer<BrandListService>(
              builder: (context, bs, child) {
                return ValueListenableBuilder<BrandModel?>(
                  valueListenable: sdm.selectedBrand,
                  builder: (context, selected, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: context.color.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.color.primaryBorderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<BrandModel>(
                          isExpanded: true,
                          value: selected,
                          hint: Text(
                            "Choose your brand",
                            style: context.bodyMedium?.copyWith(
                              color: context.color.secondaryContrastColor,
                            ),
                          ),
                          onChanged: (BrandModel? newValue) {
                            sdm.selectedBrand.value = newValue;
                          },
                          items: bs.myBrandsModel.allBrands?.map((brand) {
                            return DropdownMenuItem<BrandModel>(
                              value: brand,
                              child: Row(
                                children: [
                                  if (brand.image != null) ...[
                                    CustomNetworkImage(
                                      imageUrl: brand.image,
                                      height: 24,
                                      width: 24,
                                      radius: 4,
                                    ),
                                    12.toWidth,
                                  ],
                                  Text(
                                    brand.name ?? "Unknown Brand",
                                    style: context.bodyMedium?.bold5,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
