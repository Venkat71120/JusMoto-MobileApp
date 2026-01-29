import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/models/home_models/offer_list_model.dart';
import 'package:car_service/utils/components/custom_network_image.dart';
import 'package:car_service/views/service_by_offer_view/service_by_offer_view.dart';
import 'package:flutter/material.dart';

class LandingOfferView extends StatelessWidget {
  final Offer? offerInfo;
  const LandingOfferView({super.key, this.offerInfo});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: context.width - 80,
          decoration: BoxDecoration(),
          child: Stack(
            children: [
              ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(20),
                children: [
                  ...[
                    GestureDetector(
                      onTap: () {
                        context
                            .toPage(ServiceByOfferView(offerId: offerInfo?.id),
                                then: (_) {
                          context.pop;
                        });
                      },
                      child: CustomNetworkImage(
                        imageUrl: offerInfo?.image,
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                            onTap: () {
                              context.pop;
                            },
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: context.color.mutedContrastColor,
                                ),
                              ),
                              child: Icon(
                                Icons.close,
                                color: context.color.mutedContrastColor,
                              ),
                            ))
                      ],
                    )
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
