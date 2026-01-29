import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:flutter/material.dart';

import '../../../helper/local_keys.g.dart';
import '../../../models/service/service_details_model.dart';

class ServiceDetailsSpecifications extends StatelessWidget {
  final List<AdditionalInfo> specifications;
  const ServiceDetailsSpecifications({super.key, required this.specifications});

  @override
  Widget build(BuildContext context) {
    return specifications.isEmpty
        ? const SizedBox()
        : Container(
            margin: const EdgeInsets.only(top: 8),
            color: context.color.accentContrastColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocalKeys.additionalServices,
                  style: context.titleSmall?.bold,
                ),
                12.toHeight.divider,
                12.toHeight,
                Wrap(
                  runSpacing: 8,
                  children: specifications.map((e) {
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
                                  const Icon(
                                    Icons.access_time_outlined,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                  8.toWidth,
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      e.title ?? "",
                                      style: context.bodySmall,
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
