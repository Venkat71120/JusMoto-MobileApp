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
    final reviews = serviceDetails.allServices?.reviews ?? [];
    final avgRating = serviceDetails.allServices?.averageRating ?? 0;
    return Container(
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
                  Icons.rate_review_outlined,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              12.toWidth,
              Expanded(
                child: Text(
                  LocalKeys.reviews,
                  style: context.titleMedium?.bold.copyWith(
                    fontSize: 17,
                  ),
                ),
              ),
              if (reviews.length > 5)
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
          // Rating summary card
          if (reviews.isNotEmpty) ...[
            20.toHeight,
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor.withOpacity(0.06),
                    primaryColor.withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: primaryColor.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  // Left side - big rating
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.color.accentContrastColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          avgRating.toStringAsFixed(1),
                          style: context.headlineLarge?.bold.copyWith(
                            fontSize: 28,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      10.toHeight,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (i) {
                          return Icon(
                            i < avgRating.round()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: Colors.orange.shade600,
                            size: 20,
                          );
                        }),
                      ),
                      6.toHeight,
                      Text(
                        "${reviews.length} ${LocalKeys.reviews.toLowerCase()}",
                        style: context.bodySmall?.copyWith(
                          color: context.color.tertiaryContrastColo,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  28.toWidth,
                  // Right side - bar chart
                  Expanded(
                    child: Column(
                      children: List.generate(5, (i) {
                        final star = 5 - i;
                        final count = reviews
                            .where((r) => r.rating.round() == star)
                            .length;
                        final ratio =
                            reviews.isEmpty ? 0.0 : count / reviews.length;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 14,
                                child: Text(
                                  "$star",
                                  style: context.bodySmall?.bold5.copyWith(
                                    color: context.color.tertiaryContrastColo,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              6.toWidth,
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: ratio,
                                    minHeight: 8,
                                    backgroundColor: context
                                        .color.primaryBorderColor
                                        .withOpacity(0.4),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.orange.shade600,
                                    ),
                                  ),
                                ),
                              ),
                              8.toWidth,
                              SizedBox(
                                width: 24,
                                child: Text(
                                  "$count",
                                  style: context.bodySmall?.copyWith(
                                    color: context.color.tertiaryContrastColo,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
          20.toHeight,
          reviews.isEmpty
              ? Center(child: EmptyElement(text: LocalKeys.noRatingsFound))
              : Column(
                  children: reviews.map((review) {
                    return Column(
                      children: [
                        RatingTile(
                          userImage: review.reviewer?.image ?? "",
                          userName: review.reviewer?.name,
                          email: review.reviewer?.email ?? "****",
                          rating: review.rating.toDouble(),
                          description: review.message,
                          createdAt: review.createdAt,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        if (review != reviews.lastOrNull)
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
