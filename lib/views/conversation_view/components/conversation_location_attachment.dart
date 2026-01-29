import 'package:flutter/material.dart';

import '/helper/extension/context_extension.dart';
import '/helper/extension/string_extension.dart';
import '/helper/local_keys.g.dart';
import '/helper/svg_assets.dart';
import '/utils/components/empty_spacer_helper.dart';
import '../../../customizations/colors.dart';

class ConversationLocationAttachment extends StatelessWidget {
  const ConversationLocationAttachment({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(maxWidth: context.width / 1.5),
      decoration: BoxDecoration(
        color: context.color.primaryContrastColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                  height: 38,
                  width: 38,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor,
                  ),
                  child: SvgAssets.mapPin.toSVGSized(20)),
              EmptySpaceHelper.emptyWidth(8),
              Column(
                children: [
                  Text(
                    LocalKeys.address,
                    style: context.titleMedium?.bold6.copyWith(fontSize: 14.0),
                  ),
                ],
              )
            ],
          ),
          EmptySpaceHelper.emptyHeight(8),
        ],
      ),
    );
  }
}
