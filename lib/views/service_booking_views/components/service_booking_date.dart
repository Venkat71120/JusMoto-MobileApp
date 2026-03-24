import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/view_models/service_booking_view_model/service_booking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/schedule_list_model.dart';

class ServiceBookingDate extends StatelessWidget {
  final dynamic providerId;
  final dynamic admin;
  const ServiceBookingDate({super.key, this.providerId, this.admin});

  @override
  Widget build(BuildContext context) {
    final svm = ServiceBookingViewModel.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                color: primaryColor,
                size: 18,
              ),
            ),
            10.toWidth,
            Text(
              LocalKeys.dateAndSchedule,
              style: context.titleSmall?.bold.copyWith(fontSize: 14),
            ),
          ],
        ),
        16.toHeight,

        // Date selector — horizontal scrollable dates
        ValueListenableBuilder(
          valueListenable: svm.selectedDate,
          builder: (context, selectedDate, child) {
            final now = DateTime.now();
            return SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 14,
                separatorBuilder: (_, __) => 8.toWidth,
                itemBuilder: (context, index) {
                  final date = now.add(Duration(days: index));
                  final isSelected = selectedDate != null &&
                      date.day == selectedDate.day &&
                      date.month == selectedDate.month &&
                      date.year == selectedDate.year;

                  return GestureDetector(
                    onTap: () {
                      svm.selectedDate.value = date;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 58,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor
                            : context.color.mutedContrastColor,
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected
                            ? null
                            : Border.all(
                                color: context.color.primaryBorderColor,
                              ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat("EEE").format(date).toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.8)
                                  : context.color.tertiaryContrastColo,
                            ),
                          ),
                          4.toHeight,
                          Text(
                            "${date.day}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : context.color.primaryContrastColor,
                            ),
                          ),
                          2.toHeight,
                          Text(
                            DateFormat("MMM").format(date),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.8)
                                  : context.color.tertiaryContrastColo,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        20.toHeight,

        // Time selector
        Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: context.color.tertiaryContrastColo,
              size: 16,
            ),
            6.toWidth,
            Text(
              "Select Time",
              style: context.bodySmall?.bold6.copyWith(
                color: context.color.secondaryContrastColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
        12.toHeight,

        // Time slot grid
        ValueListenableBuilder(
          valueListenable: svm.selectedTime,
          builder: (context, selectedTime, child) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _generateTimeSlots().map((time) {
                final isSelected = selectedTime != null &&
                    selectedTime.hour == time.hour &&
                    selectedTime.minute == time.minute;

                return GestureDetector(
                  onTap: () {
                    svm.selectedTime.value = time;
                    // Auto-set date to today if not selected
                    svm.selectedDate.value ??= DateTime.now();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor
                          : context.color.mutedContrastColor,
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? null
                          : Border.all(
                              color: context.color.primaryBorderColor,
                            ),
                    ),
                    child: Text(
                      _formatTime(time),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : context.color.primaryContrastColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),

        // Show selected summary
        ValueListenableBuilder(
          valueListenable: svm.selectedDate,
          builder: (context, date, child) {
            return ValueListenableBuilder(
              valueListenable: svm.selectedTime,
              builder: (context, time, child) {
                if (date == null || time == null) {
                  return const SizedBox.shrink();
                }
                return Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: primaryColor,
                        size: 18,
                      ),
                      10.toWidth,
                      Expanded(
                        child: Text(
                          "${DateFormat('EEEE, dd MMMM').format(date)} at ${_formatTime(time)}",
                          style: context.bodySmall?.bold6.copyWith(
                            color: primaryColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  List<TimeOfDay> _generateTimeSlots() {
    final slots = <TimeOfDay>[];
    for (int hour = 8; hour <= 20; hour++) {
      slots.add(TimeOfDay(hour: hour, minute: 0));
      if (hour < 20) {
        slots.add(TimeOfDay(hour: hour, minute: 30));
      }
    }
    return slots;
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
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
