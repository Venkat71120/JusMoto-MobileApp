import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:car_service/views/personal_information_view/personal_information_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/profile_services/profile_info_service.dart';
import '../../../services/theme_service.dart';

class MenuUserTile extends StatelessWidget {
  const MenuUserTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileInfoService>(builder: (context, pi, child) {
      return GestureDetector(
        onTap: () {
          context.toPage(const PersonalInformationView());
        },
        child: Consumer<ThemeService>(builder: (context, ts, child) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: context.color.accentContrastColor,
            child: Row(
              children: [
                CustomNetworkImage(
                  height: 52,
                  width: 52,
                  radius: 26,
                  imageUrl: pi.profileInfoModel.userDetails?.image,
                  name: pi.profileInfoModel.userDetails?.firstName,
                  fit: BoxFit.cover,
                ),
                8.toWidth,
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${pi.profileInfoModel.userDetails?.firstName ?? ""} ${pi.profileInfoModel.userDetails?.lastName ?? ""}",
                        style: context.titleLarge?.bold,
                      ),
                      4.toHeight,
                      Text(
                        pi.profileInfoModel.userDetails?.email ?? "",
                        style: context.bodyMedium,
                      ),
                    ],
                  ),
                ),
                SvgAssets.chevron.toSVGSized(
                  20,
                  color: context.color.secondaryContrastColor,
                ),
              ],
            ),
          );
        }),
      );
    });
  }
}
