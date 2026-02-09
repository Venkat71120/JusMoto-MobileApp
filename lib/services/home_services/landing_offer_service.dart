// import 'package:car_service/helper/app_urls.dart';
// import 'package:car_service/helper/constant_helper.dart';
// import 'package:flutter/material.dart';

// import '../../data/network/network_api_services.dart';
// import '../../models/home_models/offer_list_model.dart';
// import '../../views/landing_offer_view/landing_offer_view.dart';

// class LandingOfferService {
//   final ValueNotifier<num> notificationCount = ValueNotifier(0);
//   final ValueNotifier<num> messageCount = ValueNotifier(0);

//   Offer? primaryOffer;

//   LandingOfferService._init();
//   static LandingOfferService? _instance;
//   static LandingOfferService get instance {
//     _instance ??= LandingOfferService._init();
//     return _instance!;
//   }

//   LandingOfferService._dispose();
//   static bool get dispose {
//     _instance = null;
//     return true;
//   }

//   fetchPrimaryOfferContent(BuildContext context) async {
//     if (primaryOffer != null) return;
//     var url = AppUrls.primaryOfferUrl;

//     final responseData = await NetworkApiServices().getApi(
//       url,
//       null,
//       headers: acceptJsonAuthHeader,
//     );

//     if (responseData != null) {
//       final tempData = OfferListModel.fromJson(responseData);
//       primaryOffer = tempData.offers.firstOrNull;
//     }
//     if ((primaryOffer?.image ?? '').trim().isNotEmpty) return;
//     showDialog(
//       context: context,
//       builder: (context) => LandingOfferView(offerInfo: primaryOffer),
//     );
//   }
// }
