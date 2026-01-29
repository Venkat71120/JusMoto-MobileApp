import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/field_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../view_models/submit_review_view_model/submit_review_view_model.dart';

class SubmitReviewStars extends StatelessWidget {
  const SubmitReviewStars({super.key});

  @override
  Widget build(BuildContext context) {
    final srm = SubmitReviewViewModel.instance;
    return SquircleContainer(
      padding: const EdgeInsets.all(12),
      color: context.color.accentContrastColor,
      radius: 12,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(label: LocalKeys.overallRatingForCustomer),
          ValueListenableBuilder(
            valueListenable: srm.ratingCountNotifier,
            builder: (context, rating, child) => RatingBar.builder(
                initialRating: rating,
                itemSize: (context.width - 112) / 5,
                itemBuilder: (context, index) {
                  return SquircleContainer(
                      radius: 8,
                      padding: 12.paddingAll,
                      borderColor: context.color.primaryBorderColor,
                      margin: 8.paddingH,
                      child: Icon(
                        Icons.star_rounded,
                        size: 24,
                        color: context.color.primaryPendingColor,
                      ));
                },
                onRatingUpdate: (v) {
                  srm.ratingCountNotifier.value = v;
                }),
          )
        ],
      ),
    );
  }
}
