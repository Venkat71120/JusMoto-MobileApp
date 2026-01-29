import 'dart:async';

import 'package:car_service/helper/extension/int_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/extension/context_extension.dart';
import '../../helper/extension/string_extension.dart';
import '../../helper/local_keys.g.dart';
import '../../helper/svg_assets.dart';
import '../../models/address_models/states_model.dart';
import '../../services/address_services/states_service.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/field_label.dart';
import 'custom_squircle_widget.dart';
import 'empty_spacer_helper.dart';

class StatesDropdown extends StatelessWidget {
  final String? hintText;
  final String? textFieldHint;
  final onChanged;
  final iconColor;
  final textStyle;
  final ValueNotifier<States?> stateNotifier;
  final bool hideLabel;
  final bool? isRequired;
  const StatesDropdown(
      {this.hintText,
      this.onChanged,
      this.textFieldHint,
      this.iconColor,
      this.textStyle,
      required this.stateNotifier,
      this.hideLabel = false,
      super.key,
      this.isRequired});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: stateNotifier,
      builder: (context, selectedValue, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!hideLabel)
            FieldLabel(
              label: LocalKeys.state,
              isRequired: isRequired ?? false,
            ),
          InkWell(
            onTap: () {
              final ScrollController controller = ScrollController();
              Timer? scheduleTimeout;
              Provider.of<StatesService>(context, listen: false).resetList();
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) {
                  controller.addListener(() {
                    tryLoadingMore(context, controller);
                  });
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
                    child: Consumer<StatesService>(
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
                                        textFieldHint ?? LocalKeys.searchState,
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: SvgAssets.search.toSVG,
                                    )),
                                onChanged: (value) async {
                                  scheduleTimeout?.cancel();
                                  scheduleTimeout =
                                      Timer(const Duration(seconds: 1), () {
                                    cProvider.setStatesSearchValue(value);
                                    cProvider.getStates();
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
                                  if (cProvider.stateLoading ||
                                      (cProvider.stateDropdownList.length ==
                                              index &&
                                          cProvider.nextPage != null)) {
                                    return const SizedBox(
                                        height: 50,
                                        width: double.infinity,
                                        child:
                                            Center(child: CustomPreloader()));
                                  }
                                  if (cProvider.stateDropdownList.isEmpty) {
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
                                  if (cProvider.stateDropdownList.length ==
                                      index) {
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
                                  final element =
                                      cProvider.stateDropdownList[index];
                                  return InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                      if (element == selectedValue) {
                                        return;
                                      }
                                      stateNotifier.value = element;
                                      if (onChanged == null) {
                                        return;
                                      }
                                      onChanged(element);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 14),
                                      child: Text(
                                        element?.state ?? '',
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
                                itemCount: cProvider.stateLoading == true ||
                                        cProvider.stateDropdownList.isEmpty
                                    ? 1
                                    : cProvider.stateDropdownList.length +
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
                  Expanded(
                    flex: 1,
                    child: Text(
                      selectedValue?.state ?? LocalKeys.selectState,
                      style: context.titleSmall?.copyWith(
                          color: (selectedValue?.state == null
                              ? context.color.tertiaryContrastColo
                              : context.color.primaryContrastColor),
                          fontWeight: selectedValue?.state == null
                              ? null
                              : FontWeight.w600),
                    ),
                  ),
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
    );
  }

  tryLoadingMore(BuildContext context, controller) async {
    try {
      final cd = Provider.of<StatesService>(context, listen: false);
      final nextPage = cd.nextPage;
      final nextPageLoading = cd.nextPageLoading;

      if (controller.offset == controller.position.maxScrollExtent &&
          !controller.position.outOfRange) {
        if (nextPage != null && !nextPageLoading) {
          cd.fetchNextPage();
          return;
        }
      }
    } catch (e) {}
  }
}
