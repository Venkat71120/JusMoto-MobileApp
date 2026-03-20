import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/view_models/service_details_view_model/service_details_view_model.dart';
import 'package:car_service/views/service_details_view/components/service_details_description.dart';
import 'package:flutter/material.dart';

import '../../../models/service/service_details_model.dart';

class ServiceDetailsTabs extends StatelessWidget {
  final ServiceDetailsModel serviceDetails;
  const ServiceDetailsTabs({super.key, required this.serviceDetails});

  @override
  Widget build(BuildContext context) {
    final sdm = ServiceDetailsViewModel.instance;
    return ValueListenableBuilder(
      valueListenable: sdm.selectedTab,
      builder: (context, value, child) {
        return ServiceDetailsDescription(serviceDetails: serviceDetails);
      },
    );
  }
}
