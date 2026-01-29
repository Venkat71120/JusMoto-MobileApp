import 'dart:async';

import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/views/service_booking_address_schedule_view/outlet_map_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../customizations/colors.dart';
import '../../helper/extension/context_extension.dart';
import '../../helper/extension/string_extension.dart';
import '../../helper/local_keys.g.dart';
import '../../helper/svg_assets.dart';
import '../../models/outlet_model.dart';
import '../../services/outlet_service.dart';
import '../../utils/components/custom_preloader.dart';
import '../../utils/components/field_label.dart';
import 'custom_squircle_widget.dart';

class OutletDropdown extends StatelessWidget {
  final String? hintText;
  final String? textFieldHint;
  final ValueNotifier<Outlet?> outletNotifier;
  final void Function(Outlet)? onChanged;
  final Color? iconColor;
  final TextStyle? textStyle;
  final bool isRequired;

  const OutletDropdown(
      {this.hintText,
      required this.outletNotifier,
      this.onChanged,
      this.textFieldHint,
      this.iconColor,
      this.textStyle,
      this.isRequired = false,
      super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: outletNotifier,
      builder: (context, c, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(label: LocalKeys.outlet, isRequired: isRequired),
          InkWell(
            onTap: () {
              final ScrollController controller = ScrollController();
              Timer? scheduleTimeout;

              Provider.of<OutletService>(context, listen: false).resetList();
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
                    child: Consumer<OutletService>(
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
                                        textFieldHint ?? LocalKeys.searchOutlet,
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: SvgAssets.search.toSVGSized(24,
                                          color: context
                                              .color.secondaryContrastColor),
                                    )),
                                onChanged: (value) {
                                  scheduleTimeout?.cancel();
                                  scheduleTimeout =
                                      Timer(const Duration(seconds: 1), () {
                                    cProvider.setOutletSearchValue(value);
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
                                  if (cProvider.outletLoading ||
                                      (cProvider.outletList.length == index &&
                                          cProvider.nextPage != null)) {
                                    return const SizedBox(
                                        height: 50,
                                        width: double.infinity,
                                        child:
                                            Center(child: CustomPreloader()));
                                  }
                                  if (cProvider.outletList.isEmpty) {
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
                                  if (cProvider.outletList.length == index) {
                                    return const SizedBox();
                                  }
                                  final element = cProvider.outletList[index];
                                  return InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                      if (element == c) {
                                        return;
                                      }
                                      outletNotifier.value = element;
                                      if (onChanged == null) {
                                        return;
                                      }
                                      onChanged!(element);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 14),
                                      child: Text(
                                        element.outletName ?? "",
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
                                itemCount: cProvider.outletLoading == true ||
                                        cProvider.outletList.isEmpty
                                    ? 1
                                    : cProvider.outletList.length +
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
              radius: 8,
              color: context.color.mutedContrastColor,
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  8.toWidth,
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c?.outletName ?? LocalKeys.selectOutlet,
                          style: context.titleSmall?.copyWith(
                              color: (c?.outletName == null
                                  ? context.color.secondaryContrastColor
                                  : null),
                              fontWeight: FontWeight.w600),
                        ),
                        if (c != null) ...[
                          4.toHeight,
                          Text(
                            c.address ?? LocalKeys.selectOutlet,
                            style: context.bodySmall,
                          ),
                        ]
                      ],
                    ),
                  ),
                  SvgAssets.arrowDown.toSVGSized(24.0),
                ],
              ),
            ),
          ),
          12.toHeight,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              RichText(
                text: TextSpan(
                    text: LocalKeys.viewOutletsInMap,
                    style:
                        context.titleSmall?.bold.copyWith(color: primaryColor),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        context.toPage(OutletMapView(
                            os: Provider.of<OutletService>(context,
                                listen: false)));
                      }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
