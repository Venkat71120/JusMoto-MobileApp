import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/services/profile_services/profile_info_service.dart';
import 'package:car_service/views/menu_view/components/menu_tiles.dart';
import 'package:car_service/views/menu_view/components/menu_user_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/theme_service.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProfileInfoService>(builder: (context, pi, child) {
        return Consumer<ThemeService>(builder: (context, ts, child) {
          return Column(
            children: [
              Container(
                  height: context.viewPaddingTop,
                  color: context.color.accentContrastColor),
              Expanded(
                child: SingleChildScrollView(
                  padding: 8.paddingV,
                  child: Column(
                    children: [
                      if (pi.profileInfoModel.userDetails != null) ...[
                        const MenuUserTile(),
                        8.toHeight
                      ],
                      MenuTiles(
                          signedIn: pi.profileInfoModel.userDetails != null),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
      }),
    );
  }
}
