import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RatingTile extends StatelessWidget {
  final String userImage;
  final String? userName;
  final String? email;
  final num rating;
  final String? description;
  final DateTime? createdAt;
  final EdgeInsetsGeometry? padding;

  const RatingTile({
    super.key,
    required this.userImage,
    required this.userName,
    required this.email,
    required this.rating,
    this.description,
    this.createdAt,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SquircleContainer(
      padding: EdgeInsets.all(12),
      color: context.color.accentContrastColor,
      radius: 8,
      borderColor: context.color.mutedContrastColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomNetworkImage(
                height: 36,
                width: 36,
                radius: 16,
                imageUrl: userImage,
                name: userName,
                fit: BoxFit.cover,
                userPreloader: true,
              ),
              8.toWidth,
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName?.trim().isEmpty ?? true
                                    ? email!.obscureEmail
                                    : userName!,
                                style: context.titleMedium?.bold,
                              ),
                              if (createdAt != null) ...[
                                4.toHeight,
                                Text(
                                  DateFormat("dd MMM yyyy").format(createdAt!),
                                  style: context.bodySmall,
                                )
                              ]
                            ],
                          ),
                        ),
                        SvgAssets.star.toSVGSized(
                          16,
                          color: context.color.primaryPendingColor,
                        ),
                        4.toWidth,
                        Text(rating.toStringAsFixed(1),
                            style: context.bodySmall?.bold.copyWith(
                              color: context.color.tertiaryContrastColo,
                            )),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          if (description != null) ...[
            8.toHeight,
            Text(
              description!,
              style: context.bodyMedium,
            )
          ],
        ],
      ),
    );
  }
}
