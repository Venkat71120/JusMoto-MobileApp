import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/profile_services/profile_info_service.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/profile_image.dart';
import 'components/profile_info_tiles.dart';

class PersonalInformationView extends StatelessWidget {
  const PersonalInformationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const NavigationPopIcon(),
        title: Text(LocalKeys.personalInformation),
        backgroundColor: context.color.accentContrastColor,
      ),
      body: CustomRefreshIndicator(
        onRefresh: () async {
          await Provider.of<ProfileInfoService>(context, listen: false)
              .fetchProfileInfo();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              8.toHeight,
              const ProfileImage(),
              16.toHeight,
              const ProfileInfoTiles(),
            ],
          ),
        ),
      ),
    );
  }
}
