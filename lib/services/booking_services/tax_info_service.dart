import 'package:car_service/app_static_values.dart';
import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/view_models/service_booking_view_model/service_booking_view_model.dart';

import '../../data/network/network_api_services.dart';

class TaxInfoService {
  fetchTaxInfo({locationId, bool isJob = false}) async {
    final sbm = ServiceBookingViewModel.instance;
    var url = AppUrls.taxInfoUrl;
    final data = {
      'address': sbm.serviceMethod.value == DeliveryOption.OUTLET
          ? (sbm.selectedOutlet.value?.address ?? "")
          : sbm.addressController.text,
      'outlet_id': sbm.selectedOutlet.value?.id?.toString() ?? "",
      'state_id': sbm.selectedAddress.value?.stateId?.toString() ?? "",
      'city_id': sbm.selectedAddress.value?.cityId?.toString() ?? "",
      'latitude': sbm.selectedLatLng.value?.latitude.toString() ?? "",
      'longitude': sbm.selectedLatLng.value?.longitude.toString() ?? "",
    };
    final responseData = await NetworkApiServices()
        .postApi(data, url, LocalKeys.taxInfo, headers: acceptJsonAuthHeader);

    if (responseData != null) {
      ServiceBookingViewModel.instance.setTax(
        responseData["tax_info"].toString().tryToParse,
        responseData["tax_type"],
        responseData["delivery_charge"].toString().tryToParse,
        responseData["delivery_charge_system"],
      );
      return true;
    }
  }
}
