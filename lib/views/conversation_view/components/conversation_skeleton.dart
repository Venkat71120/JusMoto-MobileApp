import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:flutter/material.dart';

import '../../../helper/local_keys.g.dart';
import '../../../helper/svg_assets.dart';
import '../../../utils/components/custom_squircle_widget.dart';

class ConversationSkeleton extends StatelessWidget {
  const ConversationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              reverse: true,
              itemBuilder: (context, index) {
                final list = [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: index.isEven
                        ? primaryColor.withOpacity(.4)
                        : context.color.tertiaryContrastColo,
                  ),
                  12.toWidth,
                  Column(
                    children: [
                      SquircleContainer(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        width: context.width / 1.7,
                        constraints:
                            BoxConstraints(maxWidth: context.width / 1.7),
                        color: index.isEven
                            ? context.color.mutedContrastColor
                            : primaryColor.withOpacity(.5),
                        radius: 12,
                        child: const SizedBox(
                          height: 16,
                        ),
                      ),
                    ],
                  ),
                ];
                return Row(
                  mainAxisAlignment: index.isEven
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: index.isEven ? list : list.reversed.toList(),
                );
              },
              separatorBuilder: (context, index) => 12.toHeight,
              itemCount: 10),
        ).shim,
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: context.color.accentContrastColor,
              border: Border(
                  top: BorderSide(color: context.color.primaryBorderColor))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      textInputAction: TextInputAction.newline,
                      enabled: false,
                      minLines: 1,
                      maxLines: 100,
                      decoration: InputDecoration(
                        hintText: LocalKeys.message,
                      ),
                    ),
                  ),
                  12.toWidth,
                  SvgAssets.gallery.toSVGSized(24,
                      color: context.color.tertiaryContrastColo),
                  12.toWidth,
                  SvgAssets.send.toSVGSized(24,
                      color: context.color.tertiaryContrastColo),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
