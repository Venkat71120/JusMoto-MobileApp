import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/home_services/admin_staff_list_service.dart';
import 'package:car_service/utils/components/field_label.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/components/custom_future_widget.dart';
import '../../../view_models/service_booking_view_model/service_booking_view_model.dart';
import 'selectable_staff_avatar.dart';
import 'staff_avatar_list_skeleton.dart';

class ServiceStaffSelect extends StatelessWidget {
  const ServiceStaffSelect({super.key});

  @override
  Widget build(BuildContext context) {
    final sbm = ServiceBookingViewModel.instance;
    final slProvider =
        Provider.of<AdminStaffListService>(context, listen: false);

    return CustomFutureWidget(
        function:
            slProvider.shouldAutoFetch ? slProvider.fetchStaffList() : null,
        shimmer: const StaffAvatarListSkeleton(),
        child: Consumer<AdminStaffListService>(builder: (context, sl, child) {
          return ValueListenableBuilder(
              valueListenable: sbm.selectedStaff,
              builder: (context, value, child) {
                return (sl.adminStaffListModel.staffs ?? []).isEmpty
                    ? SizedBox()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FieldLabel(label: LocalKeys.selectStaff).hp20,
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Wrap(
                              spacing: 12,
                              children: (sl.adminStaffListModel.staffs ?? [])
                                  .map((staff) => SelectableStaffAvatar(
                                      id: staff.id,
                                      name: staff.fullname ?? "---",
                                      imageUrl: staff.image,
                                      onSelect: () {
                                        sbm.selectedStaff.value = staff;
                                      },
                                      isSelected: value?.id.toString() ==
                                          staff.id.toString()))
                                  .toList(),
                            ),
                          ),
                        ],
                      );
              });
        }));
  }
}
