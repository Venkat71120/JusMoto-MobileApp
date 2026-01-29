import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/view_models/order_list_view_model/order_list_view_model.dart';
import 'package:car_service/view_models/order_list_view_model/order_status_enums.dart';
import 'package:flutter/material.dart';

class OrderListPrimaryFilter extends StatelessWidget {
  const OrderListPrimaryFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final olm = OrderListViewModel.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder(
          valueListenable: olm.statusType,
          builder: (context, value, child) {
            return Container(
              color: context.color.accentContrastColor,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton(
                      multiSelectionEnabled: true,
                      style:
                          Theme.of(context).outlinedButtonTheme.style?.copyWith(
                        shape: WidgetStateProperty.resolveWith<OutlinedBorder?>(
                            (states) {
                          return const RoundedRectangleBorder();
                        }),
                        foregroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return context.color.accentContrastColor;
                          }
                          return context.color.primaryContrastColor;
                        }),
                      ),
                      segments: StatusType.values
                          .map((e) => ButtonSegment(
                                value: e,
                                label: Text(
                                  typeValues.reverse[e]?.capitalize ?? "---",
                                ),
                              ))
                          .toList(),
                      selected: value,
                      onSelectionChanged: (type) {
                        olm.setStatusType(type);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        )
      ],
    );
  }
}

enum Calendar { day, week, month, year }

class SingleChoice extends StatefulWidget {
  const SingleChoice({super.key});

  @override
  State<SingleChoice> createState() => _SingleChoiceState();
}

class _SingleChoiceState extends State<SingleChoice> {
  Calendar calendarView = Calendar.day;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Calendar>(
      segments: const <ButtonSegment<Calendar>>[
        ButtonSegment<Calendar>(
            value: Calendar.day,
            label: Text('Day'),
            icon: Icon(Icons.calendar_view_day)),
        ButtonSegment<Calendar>(
            value: Calendar.week,
            label: Text('Week'),
            icon: Icon(Icons.calendar_view_week)),
        ButtonSegment<Calendar>(
            value: Calendar.month,
            label: Text('Month'),
            icon: Icon(Icons.calendar_view_month)),
        ButtonSegment<Calendar>(
            value: Calendar.year,
            label: Text('Year'),
            icon: Icon(Icons.calendar_today)),
      ],
      selected: <Calendar>{calendarView},
      onSelectionChanged: (Set<Calendar> newSelection) {
        setState(() {
          calendarView = newSelection.first;
        });
      },
    );
  }
}
