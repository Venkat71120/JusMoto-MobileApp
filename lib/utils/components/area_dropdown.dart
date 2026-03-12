import 'dart:async';

import 'package:car_service/helper/extension/int_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/extension/context_extension.dart';
import '../../helper/extension/string_extension.dart';
import '../../helper/local_keys.g.dart';
import '../../helper/svg_assets.dart';
import '../../models/address_models/area_model.dart';
import '../../models/address_models/city_model.dart';
import '../../services/address_services/area_service.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/field_label.dart';
import 'custom_squircle_widget.dart';
import 'empty_spacer_helper.dart';

class AreaDropdown extends StatelessWidget {
  final String? hintText;
  final String? textFieldHint;
  final ValueNotifier<City?> cityNotifier;
  final ValueNotifier<Area?> areaNotifier;
  final onChanged;
  final iconColor;
  final textStyle;
  final bool isRequired;

  AreaDropdown(
      {this.hintText,
      required this.areaNotifier,
      required this.cityNotifier,
      this.onChanged,
      this.textFieldHint,
      this.iconColor,
      this.textStyle,
      super.key,
      this.isRequired = false});

  final ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: cityNotifier,
      builder: (context, s, child) => ValueListenableBuilder(
        valueListenable: areaNotifier,
        builder: (context, c, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FieldLabel(label: LocalKeys.area, isRequired: isRequired),
            InkWell(
              onTap: () {
                if (s == null) {
                  LocalKeys.selectACity.showToast();
                  return;
                }
                Provider.of<AreaService>(context, listen: false)
                    .resetList(s.id);
                Timer? scheduleTimeout;
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
                      child: Consumer<AreaService>(
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
                                      hintText:
                                          textFieldHint ?? LocalKeys.searchArea,
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: SvgAssets.search.toSVG,
                                      )),
                                  onChanged: (value) {
                                    scheduleTimeout?.cancel();
                                    scheduleTimeout =
                                        Timer(const Duration(milliseconds: 400), () {
                                      cProvider.setAreaSearchValue(value);
                                      cProvider.getArea();
                                    });
                                  }),
                            ),
                            Expanded(
                              child: Consumer<AreaService>(builder: (context, cProvider, child) {
                                // Local filtering for instant "live search" feel
                                final filteredList = cProvider.areaList.where((element) {
                                  if (cProvider.areaSearchText.isEmpty) return true;
                                  return (element.area ?? "")
                                      .toLowerCase()
                                      .contains(cProvider.areaSearchText.toLowerCase());
                                }).toList();

                                if (cProvider.areaLoading && filteredList.isEmpty) {
                                  return const Center(child: CustomPreloader());
                                }

                                if (filteredList.isEmpty && !cProvider.areaLoading) {
                                  return SizedBox(
                                    width: context.width - 60,
                                    height: 64,
                                    child: Center(
                                      child: Text(
                                        LocalKeys.noResultFound,
                                        style: textStyle,
                                      ),
                                    ),
                                  );
                                }

                                return ListView.separated(
                                    controller: controller,
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.only(
                                        right: 20, left: 20, bottom: 20),
                                    itemBuilder: (context, index) {
                                      if (index == filteredList.length) {
                                        if (cProvider.nextPage != null && !cProvider.nexLoadingFailed) {
                                          return const SizedBox(
                                              height: 50,
                                              width: double.infinity,
                                              child: Center(child: CustomPreloader()));
                                        }
                                        return const SizedBox();
                                      }

                                      final element = filteredList[index];
                                      return InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                          if (element == c) {
                                            return;
                                          }
                                          areaNotifier.value = element;
                                          if (onChanged == null) {
                                            return;
                                          }
                                          onChanged(element);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 14),
                                          child: Text(
                                            element.area ?? "",
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
                                    itemCount: filteredList.length +
                                        (cProvider.nextPage != null && !cProvider.nexLoadingFailed ? 1 : 0));
                              }),
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
                      c?.area ?? LocalKeys.selectArea,
                      style: context.titleSmall?.copyWith(
                          color: (c?.area == null
                              ? context.color.tertiaryContrastColo
                              : null),
                          fontWeight: c?.area == null ? null : FontWeight.w600),
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
      ),
    );
  }
}
