import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/svg_assets.dart';
import '../../services/category_service.dart';
import '../../utils/components/custom_future_widget.dart';
import '../../view_models/category_view_model/category_view_model.dart';
import '../home_view/components/category_card_skeleton.dart';
import 'components/category_card.dart';

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
                width: double.infinity,
                child: Center(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 24,
                    alignment: WrapAlignment.start,
                    children:
                        List.generate(14, (i) => const CategoryCardSkeleton()),
                  ),
                ),
              ),
              isLoading: cat.categoryLoading,
              child: Column(
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 24,
                    alignment: WrapAlignment.start,
                    children: cat.categoryList
                        .map((e) => GestureDetector(
                              onTap: () {},
                              child: CategoryCard(category: e),
                            ))
                        .toList(),
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
