import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

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
      'firstName': pem.fNameController.text,
      'lastName': pem.lNameController.text,
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
    
    if (AppUrls.deleteAccountUrl.toLowerCase().contains("xgenious.com")) {
      await Future.delayed(const Duration(seconds: 2));
      "This feature is turned off for demo app".showToast();
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(AppUrls.uploadAvatarUrl),
    );
    request.headers.addAll(acceptJsonAuthHeader);

    final ext = p.extension(pem.selectedImage.value!.path).toLowerCase().replaceAll('.', '');
    final mimeType = ext == 'jpg' || ext == 'jpeg' ? 'jpeg' : ext;

    request.files.add(
      await http.MultipartFile.fromPath(
        'avatar', 
        pem.selectedImage.value!.path,
        contentType: MediaType('image', mimeType),
      ),
    );
    
    final responseData = await NetworkApiServices().postWithFileApi(
      request,
      LocalKeys.profileSetup,
    );

    if (responseData != null && responseData['success'] == true) {
      LocalKeys.profileInfoUpdated.showToast();
      return true;
    } else if (responseData != null) {
      final error = responseData['error'] ?? responseData['message'] ?? 'Upload failed';
      error.toString().showToast();
    }
    return null;
  }
}
