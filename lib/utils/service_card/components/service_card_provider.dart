import 'dart:math';

import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:flutter/material.dart';

import '../../../app_static_values.dart';

class ServiceCardProvider extends StatelessWidget {
  final String imageUrl;
  final String? name;
  final String? id;
  const ServiceCardProvider({
    super.key,
    required this.imageUrl,
    required this.name,
    this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomNetworkImage(
          radius: 18,
          imageUrl: imageUrl,
          name: name,
          userPreloader: true,
          height: 36,
          width: 36,
          fit: BoxFit.cover,
          color: chatAvatarBGColors[
              (int.tryParse(id.toString()) ?? Random().nextInt(1632)) %
                  chatAvatarBGColors.length],
        ),
        4.toWidth,
        Expanded(
            child: Text(
          name ?? "---",
          style: context.bodySmall?.bold,
        ))
      ],
    );
  }
}
