import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';

class NotificationManageService {
  tryMarkingRead() async {
    var url = AppUrls.notificationReadUrl;

    final responseData = await NetworkApiServices()
        .getApi(url, null, headers: acceptJsonAuthHeader);

    if (responseData != null) {
      return true;
    }
  }

  fetchNotificationCount() async {
    var url = AppUrls.notificationReadUrl;

    final responseData = await NetworkApiServices()
        .getApi(url, null, headers: acceptJsonAuthHeader);

    if (responseData != null) {
      return true;
    }
  }
}
