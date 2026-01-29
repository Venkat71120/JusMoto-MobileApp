import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';

import '../../data/network/network_api_services.dart';

class SubmitReviewService {
  trySubmittingReview({
    orderId,
    itemId,
    rating,
    message,
    serviceId,
    providerId,
  }) async {
    var url = AppUrls.submitReviewsUrl;
    var data = {
      'message': '$message',
      'rating': '$rating',
      'service_id': '$serviceId',
      'order_id': '$orderId',
    };

    final responseData = await NetworkApiServices().postApi(
      data,
      url,
      LocalKeys.submitReview,
      headers: acceptJsonAuthHeader,
    );

    if (responseData != null) {
      LocalKeys.reviewSubmittedSuccessfully.showToast();
      return true;
    }
  }
}
