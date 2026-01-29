import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/utils/components/field_label.dart';
import 'package:car_service/view_models/service_booking_view_model/service_booking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/schedule_list_model.dart';
import '../../../utils/components/custom_squircle_widget.dart';

class ServiceBookingDate extends StatelessWidget {
  final dynamic providerId;
  final dynamic admin;
  const ServiceBookingDate({super.key, this.providerId, this.admin});

  @override
  Widget build(BuildContext context) {
    final svm = ServiceBookingViewModel.instance;
    return ValueListenableBuilder(
      valueListenable: svm.selectedDate,
      builder: (context, value, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FieldLabel(label: LocalKeys.dateAndSchedule, isRequired: true),
            GestureDetector(
              onTap: () async {
                onTap(context);
              },
              child: SquircleContainer(
                radius: 8,
                padding: 16.paddingAll,
                color: context.color.mutedContrastColor,
                child: Row(
                  children: [
                    if (value == null) ...[
                      SvgAssets.calendar.toSVGSized(
                        24,
                        color: context.color.tertiaryContrastColo,
                      ),
                      6.toWidth,
                      Text(LocalKeys.selectDateAndSchedule),
                    ],
                    if (value != null) ...[
                      Expanded(
                        flex: 1,
                        child: Text(
                          DateFormat("EEEE, dd MMMM \nhh:mm a").format(
                            DateTime(
                              value.year,
                              value.month,
                              value.day,
                              svm.selectedTime.value!.hour,
                              svm.selectedTime.value!.minute,
                            ),
                          ),
                          style: context.titleSmall,
                        ),
                      ),
                      6.toWidth,
                      GestureDetector(
                        onTap: () {
                          onTap(context);
                        },
                        child: SquircleContainer(
                          padding: 6.paddingAll,
                          borderColor: context.color.primaryBorderColor,
                          radius: 8,
                          child: SvgAssets.pencil.toSVGSized(
                            24,
                            color: context.color.tertiaryContrastColo,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  onTap(BuildContext context) async {
    final now = DateTime.now();
    final svm = ServiceBookingViewModel.instance;

    final ValueNotifier<DateTime?> selectedDate = ValueNotifier(
      svm.selectedDate.value,
    );
    final ValueNotifier<Schedule?> selectedSchedule = ValueNotifier(
      svm.selectedSchedule.value,
    );
    if (svm.selectedDate.value == null) {
      svm.dateScheduleType.value = SelectingScheduleType.date;
    }

    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(Duration(days: 90)),
      initialDate: svm.selectedDate.value ?? now,
    );
    final time = await showTimePicker(
      context: context,
      initialTime: svm.selectedTime.value ?? TimeOfDay.now(),
    );
    if (date != null && time != null) {
      svm.selectedDate.value = date;
      svm.selectedTime.value = time;
    }
    return;
  }

  Widget _button({
    required String title,
    bool isSelected = false,
    required void Function()? onPressed,
  }) {
    return isSelected
        ? ElevatedButton.icon(onPressed: () {}, label: Text(title))
        : OutlinedButton.icon(onPressed: onPressed, label: Text(title));
  }
}
