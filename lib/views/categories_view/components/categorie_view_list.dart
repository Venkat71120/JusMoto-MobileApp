import 'package:car_service/services/category_service.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/view_models/category_view_model/category_view_model.dart';
import 'package:car_service/views/home_view/components/category_card_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/category_model.dart';
import '../../category_view/components/category_card.dart';

class CategoryViewList extends StatelessWidget {
  final CategoryViewModel cvm;
  final ValueNotifier<Category?>? selectedCat;
  const CategoryViewList({super.key, required this.cvm, this.selectedCat});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryService>(builder: (context, cat, child) {
      return CustomFutureWidget(
        function: cat.shouldAutoFetch ? cat.fetchCategories() : null,
        shimmer: SizedBox(
          width: double.infinity,
          child: Center(
            child: Wrap(
              spacing: 12,
              runSpacing: 24,
              alignment: WrapAlignment.start,
              children: List.generate(14, (i) => const CategoryCardSkeleton()),
            ),
          ),
        ),
        isLoading: cat.categoryLoading,
        child: ValueListenableBuilder(
          valueListenable: selectedCat ?? cvm.selectedCategory,
          builder: (context, category, child) {
            return SizedBox(
              width: double.infinity,
              child: Center(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 24,
                  alignment: WrapAlignment.start,
                  children: cat.categoryList
                      .map((e) => GestureDetector(
                            onTap: () {
                              selectedCat?.value = e;
                              cvm.selectedCategory.value = e;
                            },
                            child: CategoryCard(
                              category: e,
                              isSelected:
                                  category?.id.toString() == e.id.toString(),
                            ),
                          ))
                      .toList(),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
