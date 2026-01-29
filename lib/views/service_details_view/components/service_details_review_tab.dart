import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/empty_element.dart';
import 'package:car_service/views/ratings_and_review_view/components/rating_tile.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../customizations/colors.dart';
import '../../../models/service/service_details_model.dart';

class ServiceDetailsReviewTab extends StatelessWidget {
  final ServiceDetailsModel serviceDetails;
  const ServiceDetailsReviewTab({
    super.key,
    required this.serviceDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  LocalKeys.reviews,
                  style: context.titleSmall?.bold,
                ),
              ),
              if ((serviceDetails.allServices?.reviews?.length ?? 0) > 5)
                RichText(
                  text: TextSpan(
                    text: LocalKeys.seeAll,
                    style:
                        context.titleSmall?.copyWith(color: primaryColor).bold,
                    recognizer: TapGestureRecognizer()..onTap = () async {},
                  ),
                ),
            ],
          ),
          16.toHeight,
          (serviceDetails.allServices?.reviews ?? []).isEmpty
              ? Center(child: EmptyElement(text: LocalKeys.noRatingsFound))
              : Column(
                  children:
                      (serviceDetails.allServices?.reviews ?? []).map((review) {
                    return Column(
                      children: [
                        RatingTile(
                          userImage: review.reviewer?.image ?? "",
                          userName: review.reviewer?.name,
                          email: review.reviewer?.email ?? "****",
                          rating: review.rating.toDouble(),
                          description: review.message,
                          createdAt: review.createdAt,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        if (review !=
                            (serviceDetails.allServices?.reviews ?? [])
                                .lastOrNull)
                          const SizedBox().divider,
                      ],
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
