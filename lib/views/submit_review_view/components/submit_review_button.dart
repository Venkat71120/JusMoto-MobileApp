import 'package:car_service/helper/extension/context_extension.dart';
import 'package:flutter/material.dart';

import '../../../helper/local_keys.g.dart';
import '../../../utils/components/custom_button.dart';
import '../../../view_models/submit_review_view_model/submit_review_view_model.dart';

class SubmitReviewButton extends StatelessWidget {
  const SubmitReviewButton({super.key});

  @override
  Widget build(BuildContext context) {
    final srm = SubmitReviewViewModel.instance;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
          color: context.color.accentContrastColor,
          border:
              Border(top: BorderSide(color: context.color.primaryBorderColor))),
      child: ValueListenableBuilder(
          valueListenable: srm.isLoading,
          builder: (context, loading, child) => CustomButton(
                onPressed: () {
                  srm.trySubmittingReview(context);
                },
                btText: LocalKeys.submit,
                isLoading: loading,
              )),
    );
  }
}
