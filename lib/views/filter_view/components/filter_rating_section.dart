import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/field_label.dart';
import 'package:car_service/view_models/filter_view_model/filter_view_model.dart';
import 'package:flutter/material.dart';

class FilterRatingSection extends StatelessWidget {
  const FilterRatingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final fvm = FilterViewModel.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: LocalKeys.rating),
        8.toHeight,
        SquircleContainer(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          radius: 12,
          borderColor: context.color.primaryBorderColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ValueListenableBuilder(
                valueListenable: fvm.ratingCount,
                builder: (context, rating, child) => Wrap(
                  children: List.generate(
                    5,
                    (index) {
                      final isLesserOrEqual =
                          (index.toDouble() + 1) <= (rating ?? 0);
                      return GestureDetector(
                        onTap: () {
                          fvm.ratingCount.value = index.toDouble() + 1;
                        },
                        child: Icon(
                          isLesserOrEqual
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 32,
                          color: isLesserOrEqual
                              ? context.color.primaryPendingColor
                              : context.color.primaryBorderColor,
                        ),
                      );
                    },
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  fvm.ratingCount.value = null;
                },
                child: Icon(
                  Icons.replay_rounded,
                  color: context.color.tertiaryContrastColo,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
