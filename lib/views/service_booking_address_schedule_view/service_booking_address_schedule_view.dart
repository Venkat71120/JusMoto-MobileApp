import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/home_services/admin_staff_list_service.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/custom_squircle_widget.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/utils/components/outlet_dropdown.dart';
import 'package:car_service/views/booking_payment_choose_view/booking_payment_choose_view.dart';
import 'package:car_service/views/service_booking_address_schedule_view/components/service_staff_select.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_static_values.dart';
import '../../utils/components/field_label.dart';
import '../../view_models/service_booking_view_model/service_booking_view_model.dart';
import '../cart_view/components/cart_service_delivery_method.dart';
import '../service_booking_view/components/service_booking_address.dart';
import '../service_booking_views/components/service_booking_date.dart';

class ServiceBookingAddressScheduleView extends StatelessWidget {
  const ServiceBookingAddressScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final sbm = ServiceBookingViewModel.instance;
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        leading: NavigationPopIcon(backgroundColor: Colors.transparent),
        title: Text(LocalKeys.serviceBookingAddressSchedule),
        backgroundColor: context.color.backgroundColor,
        centerTitle: true,
      ),
      body: CustomRefreshIndicator(
        onRefresh: () async {
          await Provider.of<AdminStaffListService>(
            context,
            listen: false,
          ).fetchStaffList();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: SquircleContainer(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: EdgeInsets.all(12),
            radius: 12,
            color: context.color.accentContrastColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CartServiceDeliveryMethod(),
                ValueListenableBuilder(
                  valueListenable: sbm.serviceMethod,
                  builder:
                      (context, value, child) =>
                          value == DeliveryOption.OUTLET
                              ? OutletDropdown(
                                hintText: LocalKeys.selectOutlet,
                                outletNotifier: sbm.selectedOutlet,
                              )
                              : ServiceBookingAddress(),
                ),
                16.toHeight,
                ServiceBookingDate(),
                16.toHeight,
                FieldLabel(label: LocalKeys.addNote),
                SquircleContainer(
                  radius: 8,
                  color: context.color.mutedContrastColor,
                  child: TextFormField(
                    controller: sbm.descriptionController,
                    minLines: 3,
                    maxLines: 6,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: LocalKeys.bookingNoteExmp,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                    onTapOutside: (event) {
                      context.unFocus;
                    },
                  ),
                ),
                16.toHeight,
                ServiceStaffSelect(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: context.color.accentContrastColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: ElevatedButton(
          onPressed: () {
            if (sbm.validateAddressSchedule) return;
            sbm.isLoading.value = false;
            context.toPage(BookingPaymentChooseView());
          },
          child: Text(LocalKeys.continueO),
        ),
      ),
    );
  }
}
