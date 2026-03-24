import 'package:car_service/helper/svg_assets.dart';
import 'package:flutter/material.dart';

import '../../../customizations/colors.dart';
import '../../../helper/extension/context_extension.dart';
import '../../../helper/extension/int_extension.dart';
import '../../../helper/extension/string_extension.dart';
import '../../../helper/local_keys.g.dart';
import '../../../models/order_models/refund_list_model.dart';
import '../../../refund_details_view/refund_details_view.dart';
import '../../../utils/components/custom_squircle_widget.dart';

class RefundListTile extends StatelessWidget {
  final RefundModel refundModel;
  const RefundListTile({super.key, required this.refundModel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.toPage(RefundDetailsView(refundId: refundModel.id));
      },
      child: SquircleContainer(
          padding: const EdgeInsets.all(8),
          margin: EdgeInsets.symmetric(horizontal: 20),
          color: context.color.accentContrastColor,
          radius: 8,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "${LocalKeys.id}: ",
                                style: context.bodySmall?.bold6,
                              ),
                              TextSpan(
                                text: "${refundModel.refundNumber ?? refundModel.id}: ",
                                style: context.bodySmall?.bold
                                    .copyWith(
                                        color:
                                            context.color.primaryContrastColor)
                                    .bold,
                              ),
                            ],
                          ),
                        ),
                        SquircleContainer(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            color: (refundModel.status ?? "pending")
                                .toString()
                                .getRefundMutedStatusColor,
                            radius: 4,
                            child: Text(
                              (refundModel.status ?? "pending").toString().getRefundStatus,
                              style: context.bodySmall?.copyWith(
                                  color: (refundModel.status ?? "pending")
                                      .toString()
                                      .getRefundPrimaryStatusColor),
                            ))
                      ],
                    ),
                    if (refundModel.cancelReason != null) ...[
                      4.toHeight,
                      Text(
                        refundModel.cancelReason!,
                        style: context.bodySmall?.copyWith(
                            color: context.color.secondaryContrastColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    8.toHeight,
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${LocalKeys.orderId}: ",
                            style: context.titleSmall?.copyWith(
                                color: context.color.secondaryContrastColor),
                          ),
                          TextSpan(
                            text: "${refundModel.order?.invoiceNumber ?? refundModel.orderId} . ",
                            style: context.bodySmall?.bold
                                .copyWith(
                                    color: context.color.primaryContrastColor)
                                .bold,
                          ),
                          TextSpan(
                            text: refundModel.amount.cur,
                            style: context.titleSmall?.bold
                                .price.copyWith(color: primaryColor)
                                .bold,
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
              SvgAssets.invisible
                  .toSVGSized(24, color: context.color.secondaryContrastColor)
            ],
          )),
    );
  }
}
