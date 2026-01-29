import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_button.dart';
import 'package:flutter/material.dart';

import '../../../helper/image_assets.dart';

class CancelOrderSheet extends StatelessWidget {
  const CancelOrderSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 4,
              width: 48,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: context.color.mutedContrastColor,
              ),
            ),
          ),
          12.toHeight,
          ImageAssets.cancel.toAImage(),
          24.toHeight,
          Text(LocalKeys.requestToCancel,
              style: context.titleLarge?.bold.copyWith(
                fontSize: 20,
              )),
          8.toHeight,
          Text(
            LocalKeys.requestToCancelDesc,
            textAlign: TextAlign.center,
            style: context.bodyMedium,
          ),
          24.toHeight,
          Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () {
                    context.pop;
                  },
                  child: Text(LocalKeys.back),
                ),
              ),
              12.toWidth,
              Expanded(
                flex: 1,
                child: CustomButton(
                  onPressed: () {},
                  btText: LocalKeys.requestToCancel,
                  backgroundColor: context.color.primaryWarningColor,
                ),
              ),
            ],
          ),
          24.toHeight,
        ],
      ),
    );
  }
}
