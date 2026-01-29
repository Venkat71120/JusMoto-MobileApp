import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/field_with_label.dart';
import 'package:flutter/material.dart';

import '../../../view_models/submit_review_view_model/submit_review_view_model.dart';

class SubmitReviewComment extends StatelessWidget {
  const SubmitReviewComment({super.key});

  @override
  Widget build(BuildContext context) {
    final srm = SubmitReviewViewModel.instance;
    return SquircleContainer(
      padding: const EdgeInsets.all(12),
      color: context.color.accentContrastColor,
      radius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldWithLabel(
            label: LocalKeys.comment,
            hintText: LocalKeys.describeYourExperience,
            minLines: 3,
            controller: srm.commentController,
            validator: (value) {
              if ((value ?? "").isEmpty) {
                return LocalKeys.enterAComment;
              }
              return null;
            },
          )
        ],
      ),
    );
  }
}
