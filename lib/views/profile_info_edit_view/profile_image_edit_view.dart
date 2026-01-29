import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/utils/components/alerts.dart';
import 'package:flutter/material.dart';

class ProfileImageEditView extends StatelessWidget {
  const ProfileImageEditView({super.key});

  @override
  Widget build(BuildContext context) {
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
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
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
                      SvgAssets.cameraUp.toSVGSized(100, color: primaryColor),
                    ],
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
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                  onPressed: () {}, child: Text(LocalKeys.skipForLater)),
            ),
            12.toHeight,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    Alerts().showInfoDialogue(
                        context: context,
                        title: LocalKeys.congrats,
                        description: LocalKeys.youHaveSignedUpSuccessfully,
                        infoAsset: SvgAssets.addFilled.toSVGSized(
                          100,
                          color: context.color.primarySuccessColor,
                        ));
                  },
                  child: Text(LocalKeys.continueO)),
            ),
            24.toHeight,
          ],
        ),
      ),
    );
  }
}
