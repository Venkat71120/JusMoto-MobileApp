import 'dart:io';

import 'package:car_service/helper/extension/string_extension.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_static_values.dart';
import '../../helper/local_keys.g.dart';
import '../../services/profile_services/profile_edit_service.dart';
import '../../services/profile_services/profile_info_service.dart';

class ProfileEditViewModel {
  final ValueNotifier<File?> selectedImage = ValueNotifier(null);

  final TextEditingController fNameController = TextEditingController();
  final TextEditingController lNameController = TextEditingController();
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  final GlobalKey<FormState> basicFormKey = GlobalKey();
  final GlobalKey<FormState> idFormKey = GlobalKey();

  ProfileEditViewModel._init();
  static ProfileEditViewModel? _instance;
  static ProfileEditViewModel get instance {
    _instance ??= ProfileEditViewModel._init();
    return _instance!;
  }

  ProfileEditViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  void selectProfileImage() async {
    try {
      FilePickerResult? file = await FilePicker.platform.pickFiles(
          type: FileType.image);
      if (file?.files.firstOrNull?.path == null) {
        return;
      }
      final File imageFile = File(file!.paths.first!);
      num maxSize = 1024 * 1024 * (profileImageMaxSize ?? 1); // 1MB
      final num fileSize = await imageFile.length();

      if (fileSize > maxSize) {
        LocalKeys.fileSizeExceeded.showToast();
        return;
      }
      selectedImage.value = File(file.files.first.path!);
      LocalKeys.fileSelected.showToast();
    } catch (error) {
      LocalKeys.fileSelectFailed.showToast();
    }
  }

  initProfile(user) {
    fNameController.text = user.firstName ?? "";
    lNameController.text = user.lastName ?? "";
  }

  void updateBasicInfo(BuildContext context) async {
    isLoading.value = true;
    await ProfileEditService().tryUpdatingBasicInfo().then((v) {
      if (v != true) return;
      Provider.of<ProfileInfoService>(context, listen: false)
          .fetchProfileInfo();
    });
    isLoading.value = false;
  }

  void updateProfileImage(BuildContext context) async {
    isLoading.value = true;
    await ProfileEditService().tryUpdatingProfileImage().then((v) {
      if (v != true) return;
      Provider.of<ProfileInfoService>(context, listen: false)
          .fetchProfileInfo();
      Navigator.pop(context);
    });
    isLoading.value = false;
  }
}
