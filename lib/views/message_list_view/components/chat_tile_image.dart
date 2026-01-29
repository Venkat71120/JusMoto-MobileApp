import 'dart:math';

import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:flutter/material.dart';

import '../../../app_static_values.dart';

class ChatTileImage extends StatelessWidget {
  final String? providerImage;
  final String? providerName;
  final bool isActive;
  final dynamic chatId;
  const ChatTileImage(
      {super.key,
      this.providerImage,
      required this.isActive,
      this.providerName,
      this.chatId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      width: 58,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CustomNetworkImage(
            height: 58,
            width: 58,
            radius: 29,
            imageUrl: providerImage,
            name: providerName,
            fit: BoxFit.cover,
            color: chatAvatarBGColors[
                (int.tryParse(chatId.toString()) ?? Random().nextInt(1632)) %
                    chatAvatarBGColors.length],
            userPreloader: true,
          ),
          Container(
            padding: 4.paddingAll,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.color.accentContrastColor,
            ),
            child: CircleAvatar(
              radius: 6,
              backgroundColor: isActive
                  ? context.color.primarySuccessColor
                  : context.color.mutedContrastColor,
            ),
          )
        ],
      ),
    );
  }
}
