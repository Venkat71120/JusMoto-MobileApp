import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/string_extension.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/local_keys.g.dart';

class SignOutService {
  trySignOut() async {
    final responseData = await NetworkApiServices().postApi(
      {},
      AppUrls.signOutUrl,
      LocalKeys.signOut,
      headers: acceptJsonAuthHeader,
    );

    if (responseData != null) {
      LocalKeys.signOutSuccessful.showToast();
      return true;
    }
  }
}
