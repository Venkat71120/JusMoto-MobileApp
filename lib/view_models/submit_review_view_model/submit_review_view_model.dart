import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/models/order_models/order_response_model.dart';
import 'package:car_service/services/order_services/order_details_service.dart';
import 'package:car_service/services/order_services/submit_review_service.dart';
import 'package:car_service/utils/components/alerts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubmitReviewViewModel {
  final TextEditingController commentController = TextEditingController();
  final ValueNotifier<double> ratingCountNotifier = ValueNotifier(5);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<OrderItem?> orderItemNotifier = ValueNotifier(null);

  SubmitReviewViewModel._init();
  static SubmitReviewViewModel? _instance;
  static SubmitReviewViewModel get instance {
    _instance ??= SubmitReviewViewModel._init();
    return _instance!;
  }

  static bool get dispose {
    _instance = null;
    return true;
  }

  void trySubmittingReview(BuildContext context) async {
    Alerts().confirmationAlert(
      context: context,
      title: LocalKeys.areYouSure,
      buttonColor: primaryColor,
      buttonText: LocalKeys.submit,
      onConfirm: () async {
        await SubmitReviewService()
            .trySubmittingReview(
              itemId: orderItemNotifier.value?.id,
              rating: ratingCountNotifier.value,
              message: commentController.text,
              serviceId: orderItemNotifier.value?.serviceId,
              orderId:
                  Provider.of<OrderDetailsService>(
                    context,
                    listen: false,
                  ).orderDetailsModel.orderDetails?.id?.toString() ??
                  "",
            )
            .then((v) {
              if (v != true) return;
              context.pop;
              context.pop;
            });
      },
    );
  }
}
