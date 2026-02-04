import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/phone_field.dart';
import 'package:car_service/models/address_models/address_model.dart';
import 'package:car_service/models/address_models/area_model.dart';
import 'package:car_service/models/address_models/city_model.dart';
import 'package:car_service/models/address_models/states_model.dart';
import 'package:car_service/services/address_services/address_list_service.dart';
import 'package:car_service/services/address_services/manage_address_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../helper/local_keys.g.dart';
import '../../utils/components/alerts.dart';

class AddEditAddressViewModel {
  final TextEditingController titlePassController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emergencyPhoneController =
      TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();

  final ValueNotifier<States?> selectedState = ValueNotifier(null);
  final ValueNotifier<City?> selectedCity = ValueNotifier(null);
  final ValueNotifier<Area?> selectedArea = ValueNotifier(null);
  final ValueNotifier<bool> selectedFromMap = ValueNotifier(false);
  final ValueNotifier<bool> disableScroll = ValueNotifier(false);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  final GlobalKey<FormState> formKey = GlobalKey();
  GoogleMapController? controller;

  final ScrollController scrollController = ScrollController();

  final ValueNotifier<Phone?> phone = ValueNotifier(null);
  final ValueNotifier<Phone?> emergencyPhone = ValueNotifier(null);
  final ValueNotifier<AddressType> selectedType =
      ValueNotifier(AddressType.home);

  dynamic addressId;

  AddEditAddressViewModel._init();
  
  static AddEditAddressViewModel? _instance;
  
  static AddEditAddressViewModel get instance {
    _instance ??= AddEditAddressViewModel._init();
    return _instance!;
  }

  // Proper instance disposal method
  void _disposeResources() {
    titlePassController.dispose();
    addressController.dispose();
    phoneController.dispose();
    emergencyPhoneController.dispose();
    zipCodeController.dispose();
    
    selectedState.dispose();
    selectedCity.dispose();
    selectedArea.dispose();
    selectedFromMap.dispose();
    disableScroll.dispose();
    isLoading.dispose();
    phone.dispose();
    emergencyPhone.dispose();
    selectedType.dispose();
    
    scrollController.dispose();
    controller?.dispose();
  }

  // Static dispose getter to cleanup singleton instance
  static bool get dispose {
    _instance?._disposeResources();
    _instance = null;
    return true;
  }

  void tryAddingAddress(BuildContext context) async {
    final valid = formKey.currentState?.validate();
    if (valid != true || !addressValidate) return;

    isLoading.value = true;
    if (addressId == null) {
      await ManageAddressService().tryAddingAddress(context).then((v) {
        if (v == true) {
          Provider.of<AddressListService>(context, listen: false)
              .fetchAddressList();
          context.pop;
        }
      });
    } else {
      await ManageAddressService().tryEditingAddress(context).then((v) {
        if (v == true) {
          Provider.of<AddressListService>(context, listen: false)
              .fetchAddressList();
          context.pop;
        }
      });
    }

    isLoading.value = false;
  }

  void tryRemovingAddress(BuildContext context, id) {
    Alerts().confirmationAlert(
      context: context,
      title: LocalKeys.areYouSure,
      buttonText: LocalKeys.remove,
      onConfirm: () async {
        await ManageAddressService().tryRemovingAddress(id).then((v) {
          if (v == true) {
            Provider.of<AddressListService>(context, listen: false)
                .removeAddress(id);
            context.pop;
          }
        });
      },
    );
  }

  void initAddress(Address address) {
    titlePassController.text = address.title ?? "";
    addressController.text = address.address ?? "";
    zipCodeController.text = address.postCode ?? "";
    phoneController.text = address.phone ?? "";
    emergencyPhoneController.text = address.emergencyPhone ?? "";
    selectedType.value =
        address.type == "1" ? AddressType.office : AddressType.home;
    addressId = address.id;
  }

  bool get addressValidate {
    if (selectedFromMap.value) {
      return true;
    } else if (selectedState.value == null) {
      LocalKeys.selectAState.showToast();
      return false;
    } else if (selectedCity.value == null) {
      LocalKeys.selectACity.showToast();
      return false;
    } else if (selectedArea.value == null) {
      LocalKeys.selectAnArea.showToast();
      return false;
    } else {
      return true;
    }
  }
}

enum AddressType { home, office }