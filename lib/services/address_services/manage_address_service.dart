import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/services/google_location_search_service.dart';
import 'package:car_service/view_models/add_edit_address_view_model/add_edit_address_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/local_keys.g.dart';

class ManageAddressService {
  tryAddingAddress(BuildContext context) async {
    var url = AppUrls.addAddressUrl;
    final aea = AddEditAddressViewModel.instance;
   final glProvider = Provider.of<GoogleLocationSearch>(context, listen: false);
if (glProvider.geoLoc?.postCode != null) {
  AddEditAddressViewModel.instance.zipCodeController.text = 
      glProvider.geoLoc!.postCode!;
}

    final data = {
      'state_id': aea.selectedState.value?.id?.toString() ?? "",
      'city_id': aea.selectedCity.value?.id?.toString() ?? "",
      'area_id': aea.selectedArea.value?.id?.toString() ?? "",
      'phone': aea.phoneController.text,
      'emergency_phone': aea.emergencyPhoneController.text,
      'post_code': aea.zipCodeController.text,
      'address': aea.addressController.text,
      'latitude': glProvider.geoLoc?.lat?.toString() ?? "",
      'longitude': glProvider.geoLoc?.lng?.toString() ?? "",
      'type': aea.selectedType.value == AddressType.home ? "0" : "1",
      'title': aea.titlePassController.text,
    };

    final responseData = await NetworkApiServices().postApi(
        data, url, LocalKeys.addAddress,
        headers: acceptJsonAuthHeader);

    if (responseData != null) {
      LocalKeys.addressAddedSuccessfully.showToast();
      return true;
    }
  }

  tryEditingAddress(BuildContext context) async {
    final aea = AddEditAddressViewModel.instance;
    var url = "${AppUrls.editAddressUrl}${aea.addressId}";
    final glProvider =
        Provider.of<GoogleLocationSearch>(context, listen: false);
    final data = {
      'state_id': aea.selectedState.value?.id?.toString() ?? "",
   'city_id': aea.selectedCity.value?.id?.toString() ?? "", // Fixed: was using selectedState
      'area_id': aea.selectedArea.value?.id?.toString() ?? "", // Fixed: was using selectedState
      'phone': aea.phoneController.text,
      'emergency_phone': aea.emergencyPhoneController.text,
      'post_code': aea.zipCodeController.text,
      'address': aea.addressController.text,
      'latitude': glProvider.geoLoc?.lat?.toString() ?? "",
      'longitude': glProvider.geoLoc?.lng?.toString() ?? "",
      'type': aea.selectedType.value == AddressType.home ? "0" : "1",
      'title': aea.titlePassController.text,
    };

    final responseData = await NetworkApiServices().postApi(
        data, url, LocalKeys.editAddress,
        headers: acceptJsonAuthHeader);

    if (responseData != null) {
      LocalKeys.addressEditedSuccessfully.showToast();
      return true;
    }
  }

  tryRemovingAddress(id) async {
    var url = "${AppUrls.deleteAddressUrl}$id";
    final data = {};

    final responseData = await NetworkApiServices().postApi(
        data, url, LocalKeys.removeAddress,
        headers: acceptJsonAuthHeader);

    if (responseData != null) {
      LocalKeys.addressRemovedSuccessfully.showToast();
      return true;
    }
  }
}
