import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/views/filter_view/components/filter_price_range.dart';
import 'package:car_service/views/filter_view/components/filter_rating_section.dart';
import 'package:flutter/material.dart';

import 'components/filter_buttons.dart';
import 'components/filter_category_list.dart';
import 'components/filter_type_buttons.dart';

class FilterView extends StatelessWidget {
  const FilterView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 4,
              width: 48,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: context.color.mutedContrastColor,
              ),
            ),
          ),
          16.toHeight,
          FilterTypeButton(),
          24.toHeight,
          const FilterCategoryList(),
          const FilterRatingSection().hp20,
          24.toHeight,
          const FilterPriceRange().hp20,
          24.toHeight,
          const FilterButtons().hp20,
          24.toHeight,
        ],
      ),
    );
  }
}
