import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/field_label.dart';
import 'package:car_service/view_models/order_list_view_model/order_list_view_model.dart';
import 'package:flutter/material.dart';

import '../../../view_models/order_list_view_model/order_status_enums.dart';
import 'order_sheet_filter_buttons.dart';

class OrderListFilterSheet extends StatelessWidget {
  const OrderListFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final olm = OrderListViewModel.instance;
    return SingleChildScrollView(
        padding: 24.paddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 4,
                width: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: context.color.mutedContrastColor,
                ),
              ),
            ),
            FieldLabel(label: LocalKeys.orderStatus),
            ValueListenableBuilder(
              valueListenable: olm.bookingStatus,
              builder: (context, value, child) {
                return Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: bookingStatusValues.map.keys.map((status) {
                    return _button(
                        title: status,
                        isSelected: bookingStatusValues.map[status] == value,
                        onPressed: () {
                          olm.setBookingStatus(
                              {bookingStatusValues.map[status]});
                        });
                  }).toList(),
                );
              },
            ),
            if (1 == 2) ...[
              16.toHeight,
              FieldLabel(label: LocalKeys.paymentStatus),
              ValueListenableBuilder(
                  valueListenable: olm.paymentStatus,
                  builder: (context, value, child) {
                    return Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: paymentStatusValues.map.keys.map((status) {
                        return _button(
                            title: status,
                            isSelected:
                                paymentStatusValues.map[status] == value,
                            onPressed: () {
                              olm.setPaymentStatus(
                                  {paymentStatusValues.map[status]});
                            });
                      }).toList(),
                    );
                  })
            ],
            16.toHeight,
            const OrderSheetFilterButtons(),
          ],
        ));
  }

  Widget _button(
      {required String title,
      bool isSelected = false,
      required void Function()? onPressed}) {
    return isSelected
        ? ElevatedButton.icon(
            onPressed: () {},
            label: Text(title),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            label: Text(title),
          );
  }
}
