import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:flutter/material.dart';

class ServiceDetailsCancellationPolicy extends StatelessWidget {
  const ServiceDetailsCancellationPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: context.color.accentContrastColor,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: context.color.mutedWarningColor,
                child: SvgAssets.verified
                    .toSVGSized(24, color: context.color.primaryWarningColor),
              ),
              12.toWidth,
              Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocalKeys.cancellationPolicy,
                        style: context.titleMedium?.bold,
                      ),
                      4.toHeight,
                      Text(
                        "All our handyman’s are verified to provide you sense of security",
                        style: context.bodySmall,
                      ),
                    ],
                  ))
            ],
          )
        ],
      ),
    );
  }
}
