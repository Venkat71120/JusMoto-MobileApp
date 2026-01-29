import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:flutter/material.dart';

import '../../utils/components/custom_button.dart';
import '../../utils/components/custom_network_image.dart';
import '../../view_models/sign_up_view_model/sign_up_view_model.dart';

class UploadProfileImageView extends StatelessWidget {
  const UploadProfileImageView({super.key});

  @override
  Widget build(BuildContext context) {
    final sum = SignUpViewModel.instance;
    return Scaffold(
      backgroundColor: context.color.accentContrastColor,
      appBar: AppBar(
        leading: const SizedBox(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LocalKeys.uploadProfilePhoto, style: context.titleLarge?.bold),
            4.toHeight,
            Text(LocalKeys.uploadYourProfilePhoto,
                style: context.titleLarge?.copyWith(
                  color: context.color.tertiaryContrastColo,
                )),
            ValueListenableBuilder(
              valueListenable: sum.profileImage,
              builder: (context, f, child) => Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      sum.selectProfileImage();
                    },
                    child: f == null
                        ? Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                                color: primaryColor.withOpacity(.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryColor,
                                  width: 2,
                                )),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgAssets.cameraUp
                                    .toSVGSized(100, color: primaryColor),
                              ],
                            ),
                          )
                        : CustomNetworkImage(
                            height: 200,
                            width: 200,
                            radius: 100,
                            filePath: f.path,
                            fit: BoxFit.cover,
                          ),
                  ),
                  24.toHeight,
                  Text(
                    LocalKeys.clickToSelectPhoto,
                    style: context.titleLarge?.bold,
                  ),
                  const Row()
                ],
              )),
            ),
            SizedBox(
              width: double.infinity,
              child: ValueListenableBuilder(
                valueListenable: sum.profileSetupLoading,
                builder: (context, loading, child) => CustomButton(
                  onPressed: () {
                    sum.tryToSetProfileInfo(context);
                  },
                  btText: (LocalKeys.continueO),
                  isLoading: loading,
                ),
              ),
            ),
            24.toHeight,
          ],
        ),
      ),
    );
  }
}
