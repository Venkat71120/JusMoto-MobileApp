import 'package:car_service/helper/extension/context_extension.dart';
import 'package:flutter/material.dart';

import '../../../app_static_values.dart';
import '../../../helper/local_keys.g.dart';
import '../../../utils/components/field_label.dart';
import '../../../view_models/service_booking_view_model/service_booking_view_model.dart';

class CartServiceDeliveryMethod extends StatelessWidget {
  const CartServiceDeliveryMethod({super.key});

  @override
  Widget build(BuildContext context) {
    final sbm = ServiceBookingViewModel.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(
          label: LocalKeys.chooseYourServiceMethod,
        ),
        ValueListenableBuilder(
          valueListenable: sbm.serviceMethod,
          builder: (context, value, child) {
            return Row(
              children: DeliveryOption.values
                  .map((option) => Expanded(
                        flex: 1,
                        child: RadioListTile(
                          title: Text(
                            serviceDeliveryOptions.reverse[option]!,
                            style: context.titleSmall?.bold,
                          ),
                          value: value == option,
                          groupValue: true,
                          onChanged: (newValue) {
                            sbm.serviceMethod.value = option;
                          },
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
