import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/services/car_services/user_cars_service.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/view_models/select_car_view_model/select_car_view_model.dart';
import 'package:car_service/views/select_car_view/select_car_view.dart';
import 'package:flutter/material.dart';

class MyCarCard extends StatelessWidget {
  final UserSelectedCarModel car;
  final bool isDefault;
  final UserCarsService ucs;

  const MyCarCard({
    super.key,
    required this.car,
    required this.isDefault,
    required this.ucs,
  });

  @override
  Widget build(BuildContext context) {
    return SquircleContainer(
      radius: 12,
      padding: const EdgeInsets.all(12),
      color: context.color.accentContrastColor,
      borderColor:
          isDefault ? primaryColor : context.color.primaryBorderColor,
      borderWidth: isDefault ? 1.5 : 1.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Car image
          CustomNetworkImage(
            imageUrl: car.carImage ?? '',
            carPlaceholder: true,
            height: 80,
            width: 80,
            radius: 8,
            fit: BoxFit.contain,
          ),
          12.toWidth,
          // Car details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: brand + name | action icons
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            car.brandName ?? "Unknown Brand",
                            style: context.labelSmall?.copyWith(
                              color: context.color.secondaryContrastColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            car.carName ?? "Unknown Model",
                            style: context.titleMedium?.bold,
                          ),
                        ],
                      ),
                    ),
                    // Edit icon
                    GestureDetector(
                      onTap: () {
                        SelectCarViewModel.dispose;
                        final scm = SelectCarViewModel.instance;
                        scm.setEditingCar(car);
                        context.toPage(const SelectCarView());
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: SvgAssets.edit
                            .toSVGSized(18, color: context.color.secondaryContrastColor),
                      ),
                    ),
                    // Delete icon
                    GestureDetector(
                      onTap: () => _showDeleteDialog(context),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: SvgAssets.trash
                            .toSVGSized(18, color: Colors.red),
                      ),
                    ),
                  ],
                ),
                // Registration row (hidden when empty)
                if (car.registrationNumber != null &&
                    car.registrationNumber!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Icon(Icons.pin, size: 14,
                            color: context.color.secondaryContrastColor),
                        const SizedBox(width: 4),
                        Text(
                          car.registrationNumber!,
                          style: context.bodySmall?.copyWith(
                            color: context.color.secondaryContrastColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                8.toHeight,
                // Default badge or Set as Default chip
                if (isDefault)
                  SquircleContainer(
                    radius: 6,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    color: primaryColor.withOpacity(0.1),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle,
                            size: 14, color: primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          "Default",
                          style: context.labelSmall?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () async {
                      await ucs.setDefaultCar(id: car.id);
                    },
                    child: SquircleContainer(
                      radius: 6,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      color: context.color.mutedContrastColor,
                      child: Text(
                        "Set as Default",
                        style: context.labelSmall?.copyWith(
                          color: context.color.secondaryContrastColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Car"),
        content: const Text(
            "Are you sure you want to delete this car from your profile?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ucs.deleteUserCar(id: car.id);
              if (success) {
                "Car deleted successfully".showToast();
              }
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
