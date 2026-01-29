import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/models/service/service_unit_model.dart';
import 'package:car_service/utils/components/field_label.dart';
import 'package:car_service/view_models/filter_view_model/filter_view_model.dart';
import 'package:car_service/views/filter_view/components/service_unit_card.dart';
import 'package:flutter/material.dart';

class FilterUnits extends StatelessWidget {
  const FilterUnits({super.key});

  @override
  Widget build(BuildContext context) {
    final fvm = FilterViewModel.instance;
    final unitsList = [
      ServiceUnit(id: 1, title: "2 Hr"),
      ServiceUnit(id: 2, title: "30 min"),
      ServiceUnit(id: 3, title: "10 sq-ft"),
      ServiceUnit(id: 4, title: "1.5 tn"),
      ServiceUnit(id: 5, title: "1 piece"),
      ServiceUnit(id: 6, title: "10 piece"),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: LocalKeys.serviceUnits).hp20,
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          scrollDirection: Axis.horizontal,
          child: Wrap(
            spacing: 12,
            children: unitsList
                .map((e) => ServiceUnitCard(
                      unit: e,
                      unitNotifier: fvm.selectedUnit,
                    ))
                .toList(),
          ),
        )
      ],
    );
  }
}
