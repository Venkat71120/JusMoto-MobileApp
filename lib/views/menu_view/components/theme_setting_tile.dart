import 'package:car_service/helper/constant_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../helper/local_keys.g.dart';
import '../../../helper/svg_assets.dart';
import '../../../services/theme_service.dart';
import 'menu_tile.dart';

class ThemeSettingTile extends StatelessWidget {
  const ThemeSettingTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, ts, child) {
        return MenuTile(
          title: LocalKeys.darkMode,
          svg: SvgAssets.moonStar,
          haveDivider: true,
          trailing: SizedBox(
            height: 22,
            child: Switch(
                value: ts.darkTheme,
                onChanged: (v) {
                  ts.changeTheme(!ts.darkTheme);
                  if (ts.darkTheme) {
                    SystemChrome.setSystemUIOverlayStyle(
                        SystemUiOverlayStyle.light);
                  } else {
                    SystemChrome.setSystemUIOverlayStyle(
                        SystemUiOverlayStyle.dark);
                  }
                  coreInit(context);
                }),
          ),
        );
      },
    );
  }
}
