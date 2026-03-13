import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:car_service/utils/components/notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../services/profile_services/profile_info_service.dart';
import '../../../services/theme_service.dart';
import '../../../view_models/home_view_model/home_view_model.dart';
import '../../personal_information_view/personal_information_view.dart';
import 'app_bar_cart.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final hm = HomeViewModel.instance;
    hm.scrollController.addListener(() {
      hm.appBarSize.value = hm.scrollController.offset;
    });
    return ValueListenableBuilder(
      valueListenable: hm.appBarSize,
      builder: (context, value, child) {
        final color =
            value < 200
                ? context.color.accentContrastColor
                : context.color.secondaryContrastColor;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Consumer<ProfileInfoService>(
            builder: (context, pi, child) {
              return Consumer<ThemeService>(
                builder: (context, ts, child) {
                  return AppBar(
                    centerTitle: false,

                    leading: pi.profileInfoModel.userDetails == null
                        ? const SizedBox()
                        : InkWell(
                            onTap: () =>
                                context.toPage(const PersonalInformationView()),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    pi.profileInfoModel.userDetails?.image !=
                                            null
                                        ? null
                                        : Border.all(
                                            color: context
                                                .color.accentContrastColor,
                                          ),
                               ),
                              child: CustomNetworkImage(
                                height: 40,
                                width: 40,
                                radius: 26,
                                userPreloader: true,
                                imageUrl:
                                    pi.profileInfoModel.userDetails?.image,
                                fit: BoxFit.cover,
                                name: pi.profileInfoModel.userDetails?.firstName,
                              ),
                            ),
                          ),
                    systemOverlayStyle:
                        value < 200
                            ? SystemUiOverlayStyle.light
                            : SystemUiOverlayStyle.dark,
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    title: InkWell(
                      onTap: () =>
                          context.toPage(const PersonalInformationView()),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          pi.profileInfoModel.userDetails == null
                              ? const SizedBox()
                              : Text(
                                  LocalKeys.welcomeBack,
                                  style: context.bodyMedium?.copyWith(
                                    color: color.withOpacity(.7),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                          4.toHeight,
                          RichText(
                            text: TextSpan(
                              text: null,
                              style: context.titleLarge?.bold.copyWith(
                                color: color,
                              ),
                              children: [
                                if (pi.profileInfoModel.userDetails?.firstName !=
                                    null)
                                  TextSpan(
                                    text: pi.profileInfoModel.userDetails
                                                ?.firstName ==
                                            null
                                        ? null
                                        : "${pi.profileInfoModel.userDetails?.firstName} ${pi.profileInfoModel.userDetails?.lastName} !",
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      Notifications(
                        showBadge: pi.profileInfoModel.userDetails != null,
                      ),
                      12.toWidth,
                      const AppBarCart(),
                      8.toWidth,
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
