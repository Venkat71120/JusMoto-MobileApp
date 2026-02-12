import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/views/category_view/components/AutoScrollCategoryList.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/svg_assets.dart';
import '../../services/category_service.dart';
import '../../utils/components/custom_future_widget.dart';
import '../../view_models/category_view_model/category_view_model.dart';
import '../home_view/components/category_card_skeleton.dart';
import 'components/category_card.dart';
// import 'components/auto_scroll_category_list.dart'; // Add this import

class CategoryView extends StatelessWidget {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final cvm = CategoryViewModel.instance;
    return Scaffold(
      backgroundColor: context.color.accentContrastColor,
      appBar: AppBar(
        leading: NavigationPopIcon(),
        title: Text(LocalKeys.category),
      ),
      body: Consumer<CategoryService>(builder: (context, cat, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: cvm.nameController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                    hintText: LocalKeys.searchCategory,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SvgAssets.search.toSVGSized(
                        24,
                        color: context.color.secondaryContrastColor,
                      ),
                    ),
                    suffixIcon: cat.categorySearchText.isEmpty
                        ? null
                        : GestureDetector(
                            onTap: () {
                              Provider.of<CategoryService>(context,
                                      listen: false)
                                  .setCategorySearchValue("");
                              cvm.nameController.clear();
                              context.unFocus;
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: SvgAssets.close.toSVGSized(
                                24,
                                color: context.color.secondaryContrastColor,
                              ),
                            ),
                          )),
                onFieldSubmitted: (value) {
                  Provider.of<CategoryService>(context, listen: false)
                      .setCategorySearchValue(value);
                },
              ),
            ),
            16.toHeight,
            CustomFutureWidget(
              function: cat.shouldAutoFetch ? cat.fetchCategories() : null,
              shimmer: SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 8,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => const CategoryCardSkeleton(),
                ),
              ),
              isLoading: cat.categoryLoading,
              child: Column(
  children: [
    // Replace Wrap with AutoScrollCategoryList
    AutoScrollCategoryList(
      categories: cat.categoryList,
      selectedCategoryId: null, // Or track selected category
      onCategoryTap: (category) {
        // Handle category tap
        print('Tapped: ${category.name}');
      },
    ),
  ],
),
            ),
          ],
        );
      }),
    );
  }
}