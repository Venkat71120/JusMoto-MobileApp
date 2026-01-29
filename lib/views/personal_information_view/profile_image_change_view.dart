import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/view_models/profile_edit_view_model/profile_edit_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/profile_services/profile_info_service.dart';
import '../../utils/components/custom_button.dart';

class ProfileImageChangeView extends StatelessWidget {
  const ProfileImageChangeView({super.key});

  @override
  Widget build(BuildContext context) {
    final pem = ProfileEditViewModel.instance;
    final pi = Provider.of<ProfileInfoService>(context, listen: false);
    return Scaffold(
      backgroundColor: context.color.accentContrastColor,
      appBar: AppBar(
        leading: const NavigationPopIcon(),
      ),
      body: Column(
        children: [
          Divider(
            height: 8,
            thickness: 8,
            color: context.color.backgroundColor,
          ),
          12.toHeight,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(LocalKeys.uploadProfilePhoto,
                      style: context.titleLarge?.bold),
                  4.toHeight,
                  Text(LocalKeys.uploadYourProfilePhoto,
                      style: context.titleLarge?.copyWith(
                        color: context.color.tertiaryContrastColo,
                      )),
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ValueListenableBuilder(
                          valueListenable: pem.selectedImage,
                          builder: (context, image, child) {
                            return GestureDetector(
                              onTap: () {
                                pem.selectProfileImage();
                              },
                              child: Container(
                                height: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: primaryColor,
                                      width: 2,
                                    )),
                                child: pem.selectedImage.value != null ||
                                        pi.profileInfoModel.profileImage
                                                ?.imgUrl !=
                                            null
                                    ? CustomNetworkImage(
                                        height: 200,
                                        width: 200,
                                        radius: 100,
                                        fit: BoxFit.cover,
                                        imageUrl: pi.profileInfoModel
                                            .profileImage?.imgUrl,
                                        filePath: image?.path,
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SvgAssets.cameraUp.toSVGSized(100,
                                              color: primaryColor),
                                        ],
                                      ),
                              ),
                            );
                          }),
                      24.toHeight,
                      Text(
                        LocalKeys.clickToSelectPhoto,
                        style: context.titleLarge?.bold,
                      ),
                      const Row()
                    ],
                  )),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
                color: context.color.accentContrastColor,
                border: Border(
                    top: BorderSide(color: context.color.primaryBorderColor))),
            child: ValueListenableBuilder(
                valueListenable: pem.isLoading,
                builder: (context, value, child) {
                  return CustomButton(
                    onPressed: () {
                      if (pem.selectedImage.value == null) {
                        LocalKeys.selectImage.showToast();
                        return;
                      }
                      pem.updateProfileImage(context);
                    },
                    btText: LocalKeys.saveChanges,
                    isLoading: value,
                  );
                }),
          ),
        ],
      ),
    );
  }
}
