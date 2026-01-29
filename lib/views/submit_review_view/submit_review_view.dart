import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/models/order_models/order_response_model.dart';
import 'package:car_service/view_models/submit_review_view_model/submit_review_view_model.dart';
import 'package:flutter/material.dart';

import './../../helper/local_keys.g.dart';
import './../../utils/components/navigation_pop_icon.dart';
import 'components/submit_review_button.dart';
import 'components/submit_review_comment.dart';
import 'components/submit_review_stars.dart';

class SubmitReviewView extends StatelessWidget {
  final OrderItem orderItem;
  const SubmitReviewView({super.key, required this.orderItem});

  @override
  Widget build(BuildContext context) {
    final srm = SubmitReviewViewModel.instance;
    return Scaffold(
      appBar: AppBar(
        leading: const NavigationPopIcon(),
        title: Text(LocalKeys.submitReview),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Column(
          children: [
            const SubmitReviewStars(),
            8.toHeight,
            const SubmitReviewComment(),
          ],
        ),
      ),
      bottomNavigationBar: const SubmitReviewButton(),
    );
  }
}
