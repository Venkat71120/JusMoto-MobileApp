import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/field_label.dart';
import 'package:car_service/view_models/filter_view_model/filter_view_model.dart';
import 'package:flutter/material.dart';

class FilterTypeButton extends StatelessWidget {
  const FilterTypeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final fvm = FilterViewModel.instance;
    return ValueListenableBuilder(
      valueListenable: fvm.selectedType,
      builder: (context, value, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FieldLabel(label: LocalKeys.searchType),
            Wrap(
              spacing: 12,
              children: [
                _button(
                  isSelected: value == SearchType.all,
                  title: LocalKeys.all,
                  searchType: SearchType.all,
                ),
                _button(
                  isSelected: value == SearchType.service,
                  title: LocalKeys.service,
                  searchType: SearchType.service,
                ),
                _button(
                  isSelected: value == SearchType.product,
                  title: LocalKeys.products,
                  searchType: SearchType.product,
                ),
              ],
            ),
          ],
        );
      },
    ).hp20;
  }

  _button({
    required String title,
    required SearchType searchType,
    bool isSelected = false,
  }) {
    return isSelected
        ? ElevatedButton(onPressed: () {}, child: Text(title))
        : OutlinedButton(
          onPressed: () {
            FilterViewModel.instance.selectedType.value = searchType;
          },
          child: Text(title),
        );
  }
}
