import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/empty_widget.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/view_models/ratings_and_review_view_model/ratings_and_review_view_model.dart';
import 'package:car_service/views/ratings_and_review_view/components/rating_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/rating_and_reviews_service.dart';
import '../../utils/components/scrolling_preloader.dart';
import 'components/rr_list_skeleton.dart';

class RatingsAndReviewView extends StatelessWidget {
  const RatingsAndReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final rrProvider =
        Provider.of<RatingAndReviewsService>(context, listen: false);
    final rrm = RatingsAndReviewViewModel.instance;
    rrm.scrollController.addListener(() {
      rrm.tryToLoadMore(context);
    });
    return Scaffold(
        appBar: AppBar(
          leading: const NavigationPopIcon(),
          title: Text(
            LocalKeys.ratingAndReviews,
          ),
        ),
        body: CustomRefreshIndicator(
          onRefresh: () async {
            await rrProvider.fetchRatingAndReviewsList();
          },
          child: CustomFutureWidget(
            function: rrProvider.shouldAutoFetch
                ? rrProvider.fetchRatingAndReviewsList()
                : null,
            shimmer: const RrListSkeleton(),
            child: Consumer<RatingAndReviewsService>(
                builder: (context, rr, child) {
              if (rr.ratingAndReviewsModel.clientAllReviews.isEmpty) {
                return EmptyWidget(
                  title: LocalKeys.noRatingsFound,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                );
              }
              return Scrollbar(
                  controller: rrm.scrollController,
                  child: CustomScrollView(
                    controller: rrm.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      8.toHeight.toSliver,
                      SliverList.separated(
                        itemBuilder: (context, index) {
                          final review =
                              rr.ratingAndReviewsModel.clientAllReviews[index];
                          return RatingTile(
                            userImage: review.reviewer?.image ?? "",
                            userName: review.reviewer?.name ?? "",
                            email: "**",
                            rating: review.rating,
                            description: review.message,
                            createdAt: review.createdAt,
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox().divider.hp20,
                        itemCount:
                            rr.ratingAndReviewsModel.clientAllReviews.length,
                      ),
                      if (rr.nextPage != null && !rr.nexLoadingFailed) ...[
                        16.toHeight.toSliver,
                        ScrollPreloader(loading: rr.nextPageLoading).toSliver,
                        16.toHeight.toSliver
                      ],
                    ],
                  ));
            }),
          ),
        ));
  }
}
