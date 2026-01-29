import 'dart:async';

import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/extension/context_extension.dart';
import '../../helper/extension/string_extension.dart';
import '../../helper/local_keys.g.dart';
import '../../helper/svg_assets.dart';
import '../../services/category_service.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/field_label.dart';
import 'custom_squircle_widget.dart';
import 'empty_spacer_helper.dart';

class CategoryDropdown extends StatelessWidget {
  final String? hintText;
  final String? textFieldHint;
  final ValueNotifier<Category?> categoryNotifier;
  final void Function(Category)? onChanged;
  final Color? iconColor;
  final TextStyle? textStyle;
  final bool isRequired;

  const CategoryDropdown(
      {this.hintText,
      required this.categoryNotifier,
      this.onChanged,
      this.textFieldHint,
      this.iconColor,
      this.textStyle,
      this.isRequired = false,
      super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: categoryNotifier,
      builder: (context, c, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(label: LocalKeys.category, isRequired: isRequired),
          InkWell(
            onTap: () {
              final ScrollController controller = ScrollController();
              Timer? scheduleTimeout;

              Provider.of<CategoryService>(context, listen: false).resetList();
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      color: context.color.accentContrastColor,
                    ),
                    constraints: BoxConstraints(
                        maxHeight: context.height / 2 +
                            (MediaQuery.of(context).viewInsets.bottom / 2)),
                    child: Consumer<CategoryService>(
                        builder: (context, cProvider, child) {
                      return Column(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 4,
                              width: 48,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: context.color.primaryBorderColor,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: TextFormField(
                                decoration: InputDecoration(
                                    hintText: textFieldHint ??
                                        LocalKeys.searchCategory,
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: SvgAssets.search.toSVG,
                                    )),
                                onChanged: (value) {
                                  scheduleTimeout?.cancel();
                                  scheduleTimeout =
                                      Timer(const Duration(seconds: 1), () {
                                    cProvider.setCategorySearchValue(value);
                                  });
                                }),
                          ),
                          Expanded(
                            child: ListView.separated(
                                controller: controller,
                                shrinkWrap: true,
                                padding: const EdgeInsets.only(
                                    right: 20, left: 20, bottom: 20),
                                itemBuilder: (context, index) {
                                  if (cProvider.categoryLoading ||
                                      (cProvider.categoryList.length == index &&
                                          cProvider.nextPage != null)) {
                                    return const SizedBox(
                                        height: 50,
                                        width: double.infinity,
                                        child:
                                            Center(child: CustomPreloader()));
                                  }
                                  if (cProvider.categoryList.isEmpty) {
                                    return SizedBox(
                                      width: context.width - 60,
                                      child: Center(
                                        child: Text(
                                          LocalKeys.noResultFound,
                                          style: textStyle,
                                        ),
                                      ),
                                    );
                                  }
                                  if (cProvider.categoryList.length == index) {
                                    return const SizedBox();
                                  }
                                  final element = cProvider.categoryList[index];
                                  return InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                      if (element == c) {
                                        return;
                                      }
                                      categoryNotifier.value = element;
                                      if (onChanged == null) {
                                        return;
                                      }
                                      onChanged!(element);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 14),
                                      child: Text(
                                        element.name ?? "",
                                        style: textStyle,
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(
                                      height: 8,
                                      child: Center(child: Divider()),
                                    ),
                                itemCount: cProvider.categoryLoading == true ||
                                        cProvider.categoryList.isEmpty
                                    ? 1
                                    : cProvider.categoryList.length +
                                        (cProvider.nextPage != null &&
                                                !cProvider.nexLoadingFailed
                                            ? 1
                                            : 0)),
                          )
                        ],
                      );
                    }),
                  );
                },
              );
            },
            child: SquircleContainer(
              height: 50,
              radius: 10,
              borderColor: context.color.primaryBorderColor,
              child: Row(
                children: [
                  8.toWidth,
                  Text(
                    c?.name ?? LocalKeys.selectCategory,
                    style: context.titleSmall?.copyWith(
                        color: (c?.name == null
                            ? context.color.secondaryContrastColor
                            : null),
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: SvgAssets.arrowDown.toSVGSized(24.0),
                  ),
                ],
              ),
            ),
          ),
          EmptySpaceHelper.emptyHeight(16),
        ],
      ),
    );
  }
}
