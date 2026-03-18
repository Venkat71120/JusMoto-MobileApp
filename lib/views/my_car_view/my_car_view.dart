import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/field_label.dart';
import 'package:car_service/view_models/landding_view_model/landding_view_model.dart';
import 'package:car_service/view_models/select_car_view_model/select_car_view_model.dart';
import 'package:car_service/views/select_car_view/select_car_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/car_services/user_cars_service.dart';
import 'components/car_fuel_card.dart';

class MyCarView extends StatefulWidget {
  const MyCarView({super.key});

  @override
  State<MyCarView> createState() => _MyCarViewState();
}

class _MyCarViewState extends State<MyCarView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserCarsService>(context, listen: false).fetchUserCars();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(LocalKeys.myCar),
        actions: [
          IconButton(
            onPressed: () {
              SelectCarViewModel.dispose;
              context.toPage(SelectCarView());
            },
            icon: const Icon(Icons.add),
            tooltip: "Add Car",
          )
        ],
      ),
      body: Consumer<UserCarsService>(builder: (context, ucs, child) {
        if (ucs.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final cars = ucs.userCarsModel.cars ?? [];

        if (cars.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 12),
                const Text("No cars added yet."),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    SelectCarViewModel.dispose;
                    context.toPage(SelectCarView());
                  },
                  child: const Text("Add a Car"),
                )
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: cars.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final car = cars[index];
            final isDefault = car.isDefault == 1 || car.isDefault == true;

            return SquircleContainer(
              radius: 12,
              padding: const EdgeInsets.all(16),
              color: context.color.accentContrastColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row: brand + car name, default badge + delete
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
                                color: Colors.grey,
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Default",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11),
                              ),
                            ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
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
                                        final success =
                                            await ucs.deleteUserCar(id: car.id);
                                        if (success) {
                                          "Car deleted successfully"
                                              .showToast();
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
                            },
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red, size: 22),
                            tooltip: "Delete Car",
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Registration number
                  Row(
                    children: [
                      const Icon(Icons.pin, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        car.registrationNumber ?? "No Registration",
                        style: context.bodyMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Action buttons
                  Row(
                    children: [
                      if (!isDefault)
                        OutlinedButton(
                          onPressed: () async {
                            await ucs.setDefaultCar(id: car.id);
                          },
                          child: const Text("Set as Default"),
                        ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          SelectCarViewModel.dispose;
                          final scm = SelectCarViewModel.instance;
                          scm.setEditingCar(car);
                          context.toPage(const SelectCarView());
                        },
                        icon:
                            SvgAssets.edit.toSVGSized(16, color: primaryColor),
                        label: Text(LocalKeys.changeCar),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}