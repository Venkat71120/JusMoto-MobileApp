import 'package:car_service/helper/extension/int_extension.dart';
import 'package:flutter/material.dart';

import '../../../helper/local_keys.g.dart';

class OrderSheetFilterButtons extends StatelessWidget {
  const OrderSheetFilterButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: OutlinedButton(
            onPressed: () {},
            child: Text(LocalKeys.resetFilter),
          ),
        ),
        12.toWidth,
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: () {},
            child: Text(LocalKeys.applyFilter),
          ),
        ),
      ],
    );
  }
}
