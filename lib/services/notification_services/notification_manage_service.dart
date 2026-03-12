import '../../services/home_services/unread_count_service.dart';
import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';

class NotificationManageService {
  tryMarkingRead({id}) async {
    var url = id != null
        ? "${AppUrls.myNotificationsListUrl}/mark-as-read/$id"
        : AppUrls.notificationReadUrl;

    final responseData = await NetworkApiServices()
        .getApi(url, null, headers: acceptJsonAuthHeader);

    if (responseData != null) {
      UnreadCountService.instance.fetchUnreadCounts();
      return true;
    }
    return false;
  }

  fetchNotificationCount() async {
    return await UnreadCountService.instance.fetchUnreadCounts();
  }
}
