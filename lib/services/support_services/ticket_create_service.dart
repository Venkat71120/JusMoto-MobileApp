import 'package:car_service/helper/extension/string_extension.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';
import '../../models/support_models/ticket_list_model.dart';

class TicketCreateService {
  createTicket(
      {title,
      priority,
      description,
      required Department selectedDepartment}) async {
    final body = {
      'title': title,
      'priority': priority,
      'description': description,
      'department_id': selectedDepartment.id.toString()
    };

    final responseData = await NetworkApiServices().postApi(
        body, AppUrls.createTicketUrl, LocalKeys.createTicket,
        headers: acceptJsonAuthHeader);

    if (responseData != null) {
      LocalKeys.ticketCreatedSuccessfully.showToast();
      return true;
    }
  }
}
