import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/view_models/filter_view_model/filter_view_model.dart';
import 'package:flutter/material.dart';

class FilterButtons extends StatelessWidget {
  const FilterButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            flex: 1,
            child: OutlinedButton(
                onPressed: () {
                  context.pop;

                  FilterViewModel.instance.reset(context);
                },
                child: Text(LocalKeys.resetFilter))),
        16.toWidth,
        Expanded(
            flex: 1,
            child: ElevatedButton(
                onPressed: () {
                  context.popTrue;
                  FilterViewModel.instance.setFilters(context);
                },
                child: Text(LocalKeys.applyFilter))),
      ],
    );
  }
}
