import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/utils/components/empty_element.dart';
import 'package:car_service/view_models/service_details_view_model/service_details_view_model.dart';
import 'package:flutter/material.dart';

import '../../../customizations/colors.dart';

import '../../../models/service/service_details_model.dart';

class ServiceDetailsFaqTab extends StatelessWidget {
  final ServiceDetailsModel serviceDetails;
  const ServiceDetailsFaqTab({super.key, required this.serviceDetails});

  @override
  Widget build(BuildContext context) {
    final sdm = ServiceDetailsViewModel.instance;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.help_outline_rounded,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              12.toWidth,
              Text(
                LocalKeys.frequentlyAskedQuestions,
                style: context.titleMedium?.bold.copyWith(
                  fontSize: 17,
                ),
              ),
            ],
          ),
          20.toHeight,
          (serviceDetails.allServices?.faqs ?? []).isEmpty
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    EmptyElement(text: LocalKeys.noFaqAdded),
                  ],
                )
              : Column(
                  children: (serviceDetails.allServices?.faqs ?? []).map((faq) {
                    final faqIndex =
                        (serviceDetails.allServices?.faqs ?? []).indexOf(faq);
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
                          child: Container(
                            margin: EdgeInsets.only(
                              bottom: faqIndex <
                                      (serviceDetails.allServices?.faqs ?? [])
                                              .length -
                                          1
                                  ? 12
                                  : 0,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryColor.withOpacity(0.05)
                                    : context.color.accentContrastColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? primaryColor.withOpacity(0.35)
                                      : context.color.primaryBorderColor,
                                  width: isSelected ? 1.5 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color:
                                              primaryColor.withOpacity(0.08),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? primaryColor
                                              : context
                                                  .color.mutedContrastColor,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Q",
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : context.color
                                                      .tertiaryContrastColo,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      12.toWidth,
                                      Expanded(
                                        child: Text(
                                          faq.title ?? "---",
                                          style: context.bodyMedium?.bold6
                                              .copyWith(
                                            color: context
                                                .color.primaryContrastColor,
                                          ),
                                        ),
                                      ),
                                      12.toWidth,
                                      AnimatedRotation(
                                        turns: isSelected ? 0.5 : 0,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? primaryColor
                                                    .withOpacity(0.1)
                                                : context
                                                    .color.mutedContrastColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: isSelected
                                                ? primaryColor
                                                : context.color
                                                    .tertiaryContrastColo,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  AnimatedCrossFade(
                                    firstChild: const SizedBox.shrink(),
                                    secondChild: Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(
                                          top: 14, left: 40),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: context
                                            .color.accentContrastColor,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        faq.description ?? "---",
                                        style: context.bodySmall?.copyWith(
                                          height: 1.6,
                                          color: context
                                              .color.secondaryContrastColor,
                                        ),
                                      ),
                                    ),
                                    crossFadeState: isSelected
                                        ? CrossFadeState.showSecond
                                        : CrossFadeState.showFirst,
                                    duration:
                                        const Duration(milliseconds: 300),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
