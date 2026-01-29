import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/services/category_service.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/view_models/category_view_model/category_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category_model.dart';
import 'components/categorie_view_list.dart';

class CategoriesView extends StatelessWidget {
  final ValueNotifier<Category?> selectedCat;
  const CategoriesView({super.key, required this.selectedCat});

  @override
  Widget build(BuildContext context) {
    final cvm = CategoryViewModel.instance;
    cvm.scrollController.addListener(() {
      cvm.tryToLoadMore(context);
    });
    return Scaffold(
      backgroundColor: context.color.accentContrastColor,
      appBar: AppBar(
        leading: const NavigationPopIcon(),
        title: Text(LocalKeys.categories),
      ),
      body: CustomRefreshIndicator(
        onRefresh: () async {
          await Provider.of<CategoryService>(context, listen: false)
              .fetchCategories();
        },
        child: Scrollbar(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            controller: cvm.scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(LocalKeys.searchOrChoseCategory,
                    style: context.headlineLarge?.bold6),
                16.toHeight,
                Consumer<CategoryService>(builder: (context, ct, child) {
                  return TextFormField(
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
                        suffixIcon: ct.categorySearchText.isEmpty
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
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
                  );
                }),
                32.toHeight,
                CategoryViewList(
                  cvm: cvm,
                  selectedCat: selectedCat,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
