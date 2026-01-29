import 'dart:async';

import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../helper/local_keys.g.dart';
import '../../../helper/svg_assets.dart';
import '../../../services/category_service.dart';
import '../../../utils/components/custom_preloader.dart';

class SubCategorySheet extends StatelessWidget {
  SubCategorySheet(
      {super.key, required this.controller, required this.subCatNotifier});

  Timer? scheduleTimeout;
  final ScrollController controller;
  final ValueNotifier subCatNotifier;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CategoryService(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: context.color.accentContrastColor,
        ),
        constraints: BoxConstraints(
            maxHeight: context.height / 2 +
                (MediaQuery.of(context).viewInsets.bottom / 2)),
        child: Consumer<CategoryService>(builder: (context, cProvider, child) {
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextFormField(
                    decoration: InputDecoration(
                        hintText: LocalKeys.searchCategory,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: SvgAssets.search.toSVG,
                        )),
                    onChanged: (value) {
                      scheduleTimeout?.cancel();
                      scheduleTimeout = Timer(const Duration(seconds: 1), () {
                        cProvider.setCategorySearchValue(value);
                      });
                    }),
              ),
              Expanded(
                child: ListView.separated(
                    controller: controller,
                    shrinkWrap: true,
                    padding:
                        const EdgeInsets.only(right: 20, left: 20, bottom: 20),
                    itemBuilder: (context, index) {
                      if (cProvider.categoryLoading ||
                          (cProvider.categoryList.length == index &&
                              cProvider.nextPage != null)) {
                        return const SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: Center(child: CustomPreloader()));
                      }
                      if (cProvider.categoryList.isEmpty) {
                        return SizedBox(
                          width: context.width - 60,
                          child: Center(
                            child: Text(
                              LocalKeys.noResultFound,
                              style: context.titleLarge?.bold6,
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
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 14),
                          child: Text(
                            element.name ?? "",
                            style: context.titleSmall?.bold6,
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(
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
      ),
    );
  }
}
