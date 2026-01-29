import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_dropdown.dart';
import 'package:car_service/utils/components/field_label.dart';
import 'package:flutter/material.dart';

class BookingOutletSelect extends StatelessWidget {
  const BookingOutletSelect({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: LocalKeys.outlet),
        CustomDropdown(LocalKeys.selectOutlet, [], (value) {}),
      ],
    );
  }
}
