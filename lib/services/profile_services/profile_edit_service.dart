import 'package:http/http.dart' as http;

import '../../data/network/network_api_services.dart';
import '../../helper/app_urls.dart';
import '../../helper/constant_helper.dart';
import '../../helper/extension/string_extension.dart';
import '../../helper/local_keys.g.dart';
import '../../view_models/profile_edit_view_model/profile_edit_view_model.dart';

class ProfileEditService {
  Future tryUpdatingBasicInfo() async {
    if (AppUrls.deleteAccountUrl.toLowerCase().contains(
      "car-service.bytesed",
    )) {
      await Future.delayed(const Duration(seconds: 2));
      "This feature is turned off for demo app".showToast();
      return;
    }
    final pem = ProfileEditViewModel.instance;
    final data = {
      'update_type': 'after_login',
      'first_name': pem.fNameController.text,
      'last_name': pem.lNameController.text,
    };

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(AppUrls.profileInfoUpdateUrl),
    );
    request.fields.addAll(data);
    request.headers.addAll(acceptJsonAuthHeader);
    if (AppUrls.deleteAccountUrl.toLowerCase().contains("xgenious.com")) {
      await Future.delayed(const Duration(seconds: 2));
      "This feature is turned off for demo app".showToast();
      return;
    }
    final responseData = await NetworkApiServices().postWithFileApi(
      request,
      LocalKeys.profileSetup,
    );

    if (responseData != null) {
      LocalKeys.profileInfoUpdated.showToast();
      return true;
    } else if (responseData != null && responseData.containsKey("message")) {
      responseData["message"]?.toString().showToast();
    }
  }

  tryUpdatingProfileImage() async {
    final pem = ProfileEditViewModel.instance;
    final data = {
      'update_type': 'after_login',
      'first_name': pem.fNameController.text,
      'last_name': pem.lNameController.text,
    };
    if (AppUrls.deleteAccountUrl.toLowerCase().contains("xgenious.com")) {
      await Future.delayed(const Duration(seconds: 2));
      "This feature is turned off for demo app".showToast();
      return;
    }
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(AppUrls.profileInfoUpdateUrl),
    );
    request.files.add(
      await http.MultipartFile.fromPath('image', pem.selectedImage.value!.path),
    );
    request.headers.addAll(acceptJsonAuthHeader);
    request.fields.addAll(data);
    final responseData = await NetworkApiServices().postWithFileApi(
      request,
      LocalKeys.profileSetup,
    );

    if (responseData != null) {
      LocalKeys.profileInfoUpdated.showToast();
      return true;
    } else if (responseData != null && responseData.containsKey("message")) {
      responseData["message"]?.toString().showToast();
    }
  }
}
