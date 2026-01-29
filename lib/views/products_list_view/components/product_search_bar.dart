import 'dart:async';

import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/services/service/product_list_service.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_models/filter_view_model/filter_view_model.dart';
import '../../filter_view/filter_view.dart';

class ProductSearchBar extends StatelessWidget {
  const ProductSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final fvm = FilterViewModel.instance;
    return Consumer<ProductListService>(
      builder: (context, ss, child) {
        return Row(
          children: [
            SizedBox(
              width: context.width - 92,
              height: 40,
              child: TextFormField(
                controller: fvm.searchController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  fillColor: context.color.accentContrastColor,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 10,
                      cornerSmoothing: 0.5,
                    ),
                    borderSide: BorderSide(
                      color: context.color.primaryBorderColor,
                      width: 1,
                    ),
                  ),
                  prefixIcon: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        child: Row(
                          children: [
                            4.toWidth,
                            SvgAssets.search.toSVGSized(
                              24,
                              color: context.color.tertiaryContrastColo,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  suffixIcon:
                      (ss.title ?? "").isEmpty
                          ? const SizedBox()
                          : GestureDetector(
                            onTap: () {
                              fvm.searchController.text = "";
                              ss.setSearchTitle("");
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FittedBox(
                                  child: Row(
                                    children: [
                                      4.toWidth,
                                      SvgAssets.close.toSVGSized(
                                        24,
                                        color:
                                            context.color.tertiaryContrastColo,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                ),
                onChanged: (value) {
                  fvm.timer?.cancel();
                  fvm.timer = Timer(const Duration(seconds: 1), () {
                    ss.setSearchTitle(fvm.searchController.text);
                  });
                },
                onFieldSubmitted: (value) {
                  ss.setSearchTitle(fvm.searchController.text);
                },
                onTapOutside: (event) {
                  context.unFocus;
                },
              ),
            ),
            12.toWidth,
            IconButton(
              onPressed: () {
                fvm.initFilters(context);

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: context.color.accentContrastColor,
                  builder: (context) => const FilterView(),
                );
              },
              iconSize: 20,
              padding: const EdgeInsets.all(10),
              icon: SvgAssets.filter.toSVGSized(
                20,
                color: context.color.primaryContrastColor,
              ),
              style: ButtonStyle(
                shape: WidgetStateProperty.resolveWith<OutlinedBorder?>((
                  states,
                ) {
                  return SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 10,
                      cornerSmoothing: 0.5,
                    ),
                    side: BorderSide(color: context.color.primaryBorderColor),
                  );
                }),
                backgroundColor: WidgetStateColor.resolveWith(
                  (states) => context.color.accentContrastColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
