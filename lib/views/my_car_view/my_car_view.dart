import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/view_models/select_car_view_model/select_car_view_model.dart';
import 'package:car_service/views/select_car_view/select_car_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/car_services/user_cars_service.dart';
import 'components/my_car_card.dart';

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

            return MyCarCard(
              car: car,
              isDefault: isDefault,
              ucs: ucs,
            );
          },
        );
      }),
    );
  }
}