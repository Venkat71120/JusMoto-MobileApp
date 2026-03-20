import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/home_services/admin_staff_list_service.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/utils/components/outlet_dropdown.dart';
import 'package:car_service/views/booking_payment_choose_view/booking_payment_choose_view.dart';
import 'package:car_service/views/service_booking_address_schedule_view/components/service_staff_select.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_static_values.dart';
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
        title: Text(
          LocalKeys.serviceBookingAddressSchedule,
          style: context.titleMedium?.bold,
        ),
        backgroundColor: context.color.backgroundColor,
        surfaceTintColor: context.color.backgroundColor,
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
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Delivery Method Card ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.color.accentContrastColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.local_shipping_outlined,
                            color: primaryColor,
                            size: 18,
                          ),
                        ),
                        10.toWidth,
                        Text(
                          LocalKeys.chooseYourServiceMethod,
                          style: context.titleSmall?.bold.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    8.toHeight,
                    CartServiceDeliveryMethod(),
                  ],
                ),
              ),
              16.toHeight,

              // ── Address Card ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.color.accentContrastColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.location_on_outlined,
                            color: primaryColor,
                            size: 18,
                          ),
                        ),
                        10.toWidth,
                        Text(
                          LocalKeys.address,
                          style: context.titleSmall?.bold.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    12.toHeight,
                    ValueListenableBuilder(
                      valueListenable: sbm.serviceMethod,
                      builder: (context, value, child) =>
                          value == DeliveryOption.OUTLET
                              ? OutletDropdown(
                                  hintText: LocalKeys.selectOutlet,
                                  outletNotifier: sbm.selectedOutlet,
                                )
                              : ServiceBookingAddress(),
                    ),
                  ],
                ),
              ),
              16.toHeight,

              // ── Date & Time Card ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.color.accentContrastColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ServiceBookingDate(),
              ),
              16.toHeight,

              // ── Staff Selection ──
              ServiceStaffSelect(),
            ],
          ),
        ),
      ),
      // ── Bottom Bar ──
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: context.color.accentContrastColor,
          border: Border(
            top: BorderSide(
              color: context.color.primaryBorderColor.withOpacity(0.5),
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () {
                if (sbm.validateAddressSchedule) return;
                sbm.isLoading.value = false;
                context.toPage(BookingPaymentChooseView());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                LocalKeys.continueO,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
