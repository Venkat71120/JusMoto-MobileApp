import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/views/profile_info_edit_view/profile_info_edit_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../helper/svg_assets.dart';
import '../../../services/profile_services/profile_info_service.dart';
import '../../../view_models/profile_edit_view_model/profile_edit_view_model.dart';
import '../../change_email_view/change_email_view.dart';
import '../../change_password_view/change_password_view.dart';
import '../../change_phone_view/change_phone_view.dart';
import '../../menu_view/components/menu_tile.dart';

class ProfileInfoTiles extends StatelessWidget {
  const ProfileInfoTiles({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final pi = Provider.of<ProfileInfoService>(context, listen: false);
    return Container(
      color: context.color.accentContrastColor,
      child: Column(
        children: [
          MenuTile(
            title: LocalKeys.editInformation,
            svg: SvgAssets.user,
            onPress: () {
              ProfileEditViewModel.dispose;
              ProfileEditViewModel.instance
                  .initProfile(pi.profileInfoModel.userDetails!);
              context.toPage(const ProfileInfoEditView());
            },
            haveDivider: true,
          ),
          MenuTile(
            title: LocalKeys.changeEmail,
            svg: SvgAssets.email,
            onPress: () {
              context.toPage(const ChangeEmailView());
            },
            haveDivider: true,
          ),
          MenuTile(
            title: LocalKeys.changePhone,
            svg: SvgAssets.phone,
            onPress: () {
              context.toPage(const ChangePhoneView());
            },
            haveDivider: true,
          ),
          MenuTile(
            title: LocalKeys.changePassword,
            svg: SvgAssets.lock,
            onPress: () {
              context.toPage(const ChangePasswordView());
            },
          ),
        ],
      ),
    );
  }
}
