import 'dart:async';

import 'package:car_service/helper/extension/int_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/extension/context_extension.dart';
import '../../helper/extension/string_extension.dart';
import '../../helper/local_keys.g.dart';
import '../../helper/svg_assets.dart';
import '../../models/address_models/city_model.dart';
import '../../models/address_models/states_model.dart';
import '../../services/address_services/city_service.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/field_label.dart';
import 'custom_squircle_widget.dart';
import 'empty_spacer_helper.dart';

class CityDropdown extends StatelessWidget {
  final String? hintText;
  final String? textFieldHint;
  ValueNotifier<States?> stateNotifier;
  ValueNotifier<City?> cityNotifier;
  final onChanged;
  final iconColor;
  final textStyle;
  final bool hideLabel;
  final bool isRequired;

  CityDropdown(
      {this.hintText,
      required this.stateNotifier,
      required this.cityNotifier,
      this.onChanged,
      this.textFieldHint,
      this.iconColor,
      this.textStyle,
      this.hideLabel = false,
      this.isRequired = false,
      super.key});

  final ScrollController controller = ScrollController();

  Timer? scheduleTimeout;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: stateNotifier,
      builder: (context, c, child) => ValueListenableBuilder(
        valueListenable: cityNotifier,
        builder: (context, s, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!hideLabel)
              FieldLabel(
                label: LocalKeys.city,
                isRequired: isRequired,
              ),
            InkWell(
              onTap: () {
                if (c == null) {
                  LocalKeys.selectAState.showToast();
                  return;
                }
                Provider.of<CityService>(context, listen: false)
                    .resetList(c.id);
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
                      child: Consumer<CityService>(
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
                                  color: context.color.tertiaryContrastColo,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: TextFormField(
                                  decoration: InputDecoration(
                                      hintText:
                                          textFieldHint ?? LocalKeys.searchCity,
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: SvgAssets.search.toSVG,
                                      )),
                                  onChanged: (value) {
                                    scheduleTimeout?.cancel();
                                    scheduleTimeout =
                                        Timer(const Duration(seconds: 1), () {
                                      cProvider.setCitySearchValue(value);
                                      cProvider.getCity();
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
                                    if (cProvider.cityLoading ||
                                        (cProvider.cityList.length == index &&
                                            cProvider.nextPage != null)) {
                                      return const SizedBox(
                                          height: 50,
                                          width: double.infinity,
                                          child:
                                              Center(child: CustomPreloader()));
                                    }
                                    if (cProvider.cityList.isEmpty) {
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
                                    if (cProvider.cityList.length == index) {
                                      return const SizedBox();
                                    }
                                    final element = cProvider.cityList[index];
                                    return InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                        if (element == s) {
                                          return;
                                        }
                                        cityNotifier.value = element;
                                        if (onChanged == null) {
                                          return;
                                        }
                                        onChanged(element);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 14),
                                        child: Text(
                                          element?.city ?? '',
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
                                  itemCount: cProvider.cityLoading == true ||
                                          cProvider.cityList.isEmpty
                                      ? 1
                                      : cProvider.cityList.length +
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
                      s?.city ?? LocalKeys.selectCity,
                      style: context.titleSmall?.copyWith(
                          color: (s?.city == null
                              ? context.color.tertiaryContrastColo
                              : context.color.primaryContrastColor),
                          fontWeight: s?.city == null ? null : FontWeight.w600),
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
            EmptySpaceHelper.emptyHeight(12),
          ],
        ),
      ),
    );
  }
}
