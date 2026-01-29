import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/empty_element.dart';
import 'package:car_service/view_models/service_details_view_model/service_details_view_model.dart';
import 'package:flutter/material.dart';

import '../../../models/service/service_details_model.dart';

class ServiceDetailsFaqTab extends StatelessWidget {
  final ServiceDetailsModel serviceDetails;
  const ServiceDetailsFaqTab({super.key, required this.serviceDetails});

  @override
  Widget build(BuildContext context) {
    final sdm = ServiceDetailsViewModel.instance;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocalKeys.frequentlyAskedQuestions,
            style: context.titleSmall?.bold,
          ),
          16.toHeight,
          (serviceDetails.allServices?.faqs ?? []).isEmpty
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    EmptyElement(text: LocalKeys.noFaqAdded),
                  ],
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (serviceDetails.allServices?.faqs ?? []).map((faq) {
                    return ValueListenableBuilder(
                      valueListenable: sdm.selectedFAQ,
                      builder: (context, value, child) {
                        final isSelected = value == faq;
                        return GestureDetector(
                          onTap: () {
                            if (isSelected) {
                              sdm.selectedFAQ.value = null;
                              return;
                            }
                            sdm.selectedFAQ.value = faq;
                          },
                          child: SquircleContainer(
                              radius: 10,
                              borderColor: context.color.mutedContrastColor,
                              color: context.color.accentContrastColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: Text(
                                            faq.title ?? "---",
                                            style: context.bodySmall?.bold
                                                .copyWith(
                                              color: context
                                                  .color.primaryContrastColor,
                                            ),
                                          )),
                                      SvgAssets.arrowDown.toSVGSized(
                                        20,
                                        color:
                                            context.color.tertiaryContrastColo,
                                      ),
                                    ],
                                  ),
                                  if (isSelected) ...[
                                    8.toHeight,
                                    Text(
                                      faq.description ?? "---",
                                      style: context.bodySmall,
                                    )
                                  ]
                                ],
                              )),
                        );
                      },
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
