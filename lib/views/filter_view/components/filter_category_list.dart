import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/category_service.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/view_models/filter_view_model/filter_view_model.dart';
import 'package:car_service/views/categories_view/categories_view.dart';
import 'package:car_service/views/home_view/components/category_card_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/components/label_with_see_all.dart';
import '../../category_view/components/category_card.dart';

class FilterCategoryList extends StatelessWidget {
  const FilterCategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final fvm = FilterViewModel.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWithSeeAll(
            label: LocalKeys.categories,
            onPressed: () {
              context.toPage(CategoriesView(
                selectedCat: fvm.selectedCategory,
              ));
            }),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Consumer<CategoryService>(builder: (context, fcl, child) {
            return CustomFutureWidget(
              function: fcl.shouldAutoFetch
                  ? fcl.fetchCategories(autoFetching: true)
                  : null,
              shimmer: Wrap(
                spacing: 8,
                children: [1, 3, 6, 7, 9, 5].map((cat) {
                  return const CategoryCardSkeleton();
                }).toList(),
              ),
              child: Wrap(
                spacing: 8,
                children: fcl.categoryList
                    .map((e) => ValueListenableBuilder(
                          valueListenable: fvm.selectedCategory,
                          builder: (context, category, child) =>
                              GestureDetector(
                            onTap: () {
                              if (category?.id.toString() == e.id.toString()) {
                                fvm.selectedCategory.value = null;
                                return;
                              }
                              fvm.selectedCategory.value = e;
                            },
                            child: CategoryCard(
                              category: e,
                              isSelected:
                                  category?.id.toString() == e.id.toString(),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            );
          }),
        ),
        8.toHeight,
      ],
    );
  }
}
