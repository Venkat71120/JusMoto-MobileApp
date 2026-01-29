import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:flutter/material.dart';

import '../../../helper/svg_assets.dart';
import '../../../models/service/service_details_model.dart';

class ServiceDetailsOffers extends StatelessWidget {
  final List<AdditionalInfo> offers;
  const ServiceDetailsOffers({super.key, required this.offers});

  @override
  Widget build(BuildContext context) {
    return offers.isEmpty
        ? const SizedBox()
        : Container(
            margin: const EdgeInsets.only(top: 16),
            color: context.color.accentContrastColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocalKeys.offered,
                  style: context.titleSmall?.bold,
                ),
                12.toHeight.divider,
                12.toHeight,
                Wrap(
                  runSpacing: 8,
                  children: offers.map((e) {
                    final showDesc = ValueNotifier(false);
                    return GestureDetector(
                      onTap: () {
                        if ((e.description ?? "").isNotEmpty) {
                          showDesc.value = !showDesc.value;
                        }
                      },
                      child: ValueListenableBuilder(
                          valueListenable: showDesc,
                          builder: (context, show, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  SvgAssets.doneFilled.toSVGSized(
                                    20,
                                    color: color.primarySuccessColor,
                                  ),
                                  8.toWidth,
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      e.title ?? "",
                                      style: context.bodyMedium,
                                    ),
                                  ),
                                ]),
                              ],
                            );
                          }),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
  }
}
