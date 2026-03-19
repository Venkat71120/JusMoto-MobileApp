import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/profile_services/profile_info_service.dart';
import '../../../view_models/profile_edit_view_model/profile_edit_view_model.dart';
import '../profile_image_change_view.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileInfoService>(builder: (context, pi, child) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        color: context.color.accentContrastColor,
        child: Row(
          children: [
            CustomNetworkImage(
              height: 72,
              width: 72,
              radius: 36,
              name: pi.profileInfoModel.userDetails?.firstName,
              fit: BoxFit.cover,
              imageUrl: pi.profileInfoModel.userDetails?.image,
              userPreloader: true,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    [
                      pi.profileInfoModel.userDetails?.firstName,
                      pi.profileInfoModel.userDetails?.lastName,
                    ].where((s) => s != null && s.isNotEmpty).join(' '),
                    style: context.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (pi.profileInfoModel.userDetails?.email != null)
                    Text(
                      pi.profileInfoModel.userDetails!.email!,
                      style: context.bodySmall?.copyWith(
                        color: context.color.secondaryContrastColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
                onPressed: () {
                  ProfileEditViewModel.dispose;
                  ProfileEditViewModel.instance
                      .initProfile(pi.profileInfoModel.userDetails!);
                  context.toPage(const ProfileImageChangeView());
                },
                child: Text(LocalKeys.changeImage)),
          ],
        ),
      );
    });
  }
}
