import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/utils/components/image_view.dart';
import 'package:flutter/material.dart';

import '../../../helper/local_keys.g.dart';
import '../../../models/service/admin_staff_list_model.dart';
import '../../../utils/components/custom_network_image.dart';
import '../../../utils/components/custom_squircle_widget.dart';

class OrderDetailsStaff extends StatelessWidget {
  final Staff staff;
  const OrderDetailsStaff({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return SquircleContainer(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(8),
      color: context.color.accentContrastColor,
      radius: 8,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocalKeys.assignedStaff,
                  style: context.bodySmall?.copyWith(
                    color: context.color.tertiaryContrastColo,
                  ),
                ),
                12.toHeight,
                Row(
                  children: [
                    Hero(
                      tag: staff.image,
                      child: GestureDetector(
                        onTap: () {
                          if ((staff.image?.toString() ?? "").isNotEmpty) {
                            context.toPage(
                              ImageView(staff.image, heroTag: staff.image),
                            );
                          }
                        },
                        child: CustomNetworkImage(
                          height: 44,
                          width: 44,
                          radius: 22,
                          fit: BoxFit.cover,
                          imageUrl: staff.image,
                          name: staff.fullname,
                          userPreloader: true,
                        ),
                      ),
                    ),
                    6.toWidth,
                    Expanded(
                      flex: 1,
                      child: Text(
                        staff.fullname ?? "",
                        style: context.titleSmall?.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
