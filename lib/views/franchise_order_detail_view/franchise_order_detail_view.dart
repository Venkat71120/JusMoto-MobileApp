// ─────────────────────────────────────────────────────────────────────────────
// VIEW: franchise_order_detail_view.dart
// Location: lib/views/franchise_orders_view/franchise_order_detail_view.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/models/franchise_models/franchise_order_model.dart';
import 'package:car_service/services/Franchise_dashboard_Services/franchise_orders_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FranchiseOrderDetailView extends StatefulWidget {
  final int orderId;
  const FranchiseOrderDetailView({super.key, required this.orderId});

  @override
  State<FranchiseOrderDetailView> createState() =>
      _FranchiseOrderDetailViewState();
}

class _FranchiseOrderDetailViewState extends State<FranchiseOrderDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FranchiseOrdersService>(context, listen: false)
          .fetchOrderDetail(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FranchiseOrdersService>(
      builder: (context, os, _) {
        return Scaffold(
          backgroundColor: context.color.backgroundColor,
          body: os.isLoadingDetail
              ? const _DetailSkeleton()
              : os.hasDetailError || os.orderDetail == null
                  ? _DetailError(
                      onRetry: () =>
                          os.fetchOrderDetail(widget.orderId),
                    )
                  : _DetailContent(order: os.orderDetail!),
        );
      },
    );
  }
}

// ── Detail Content ────────────────────────────────────────────────────────────

class _DetailContent extends StatelessWidget {
  final FranchiseOrderDetailModel order;
  const _DetailContent({required this.order});

  Color _statusColor(int code) {
    switch (code) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.teal;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatGateway(String raw) {
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty
            ? ''
            : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.statusCode);
    final isPaid = order.paymentStatus.toLowerCase() == 'paid';

    return CustomScrollView(
      slivers: [
        // ── SliverAppBar with gradient ──────────────────────────────────
        SliverAppBar(
          expandedHeight: 130,
          pinned: true,
          backgroundColor: primaryColor,
          surfaceTintColor: primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '#${order.invoiceNumber}',
                        style: context.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      6.toHeight,
                      Row(
                        children: [
                          _WhiteBadge(
                            label: order.status,
                            color: statusColor,
                          ),
                          SizedBoxExtension(8).toWidth,
                          _WhiteBadge(
                            label: order.paymentStatus,
                            color: isPaid ? Colors.green : Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // ── Content ─────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Schedule card ──────────────────────────────────────
                _SectionCard(
                  children: [
                    _IconRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date',
                      value: order.date,
                    ),
                    8.toHeight,
                    _IconRow(
                      icon: Icons.access_time_outlined,
                      label: 'Schedule',
                      value: order.schedule,
                    ),
                    8.toHeight,
                    _IconRow(
                      icon: Icons.receipt_outlined,
                      label: 'Payment',
                      value: _formatGateway(order.paymentGateway),
                    ),
                    if (order.transactionId != null) ...[
                      8.toHeight,
                      _IconRow(
                        icon: Icons.tag_outlined,
                        label: 'Transaction ID',
                        value: order.transactionId!,
                      ),
                    ],
                  ],
                ),
                16.toHeight,

                // ── Customer card ──────────────────────────────────────
                _SectionHeader(title: 'Customer'),
                8.toHeight,
                _SectionCard(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              order.customer.name.isNotEmpty
                                  ? order.customer.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        SizedBoxExtension(14).toWidth,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.customer.name,
                                style: context.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (order.customer.email != null) ...[
                                4.toHeight,
                                _LabelValue(
                                    icon: Icons.email_outlined,
                                    value: order.customer.email!),
                              ],
                              if (order.customer.phone != null) ...[
                                4.toHeight,
                                _LabelValue(
                                    icon: Icons.phone_outlined,
                                    value: order.customer.phone!),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                16.toHeight,

                // ── Location card ──────────────────────────────────────
                if (order.location?.address != null) ...[
                  _SectionHeader(title: 'Service Location'),
                  8.toHeight,
                  _SectionCard(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 18, color: primaryColor),
                          SizedBoxExtension(10).toWidth,
                          Expanded(
                            child: Text(
                              order.location!.address!,
                              style: context.bodySmall?.copyWith(
                                color: context.color.secondaryContrastColor
                                    .withOpacity(0.7),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  16.toHeight,
                ],

                // ── Staff card ─────────────────────────────────────────
                if (order.staff != null) ...[
                  _SectionHeader(title: 'Assigned Staff'),
                  8.toHeight,
                  _SectionCard(
                    children: [
                      _IconRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Staff',
                        value: order.staff!.name,
                      ),
                    ],
                  ),
                  16.toHeight,
                ],

                // ── Order Items ────────────────────────────────────────
                _SectionHeader(title: 'Order Items'),
                8.toHeight,
                _SectionCard(
                  padding: EdgeInsets.zero,
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order.items.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: Colors.grey.withOpacity(0.12),
                      ),
                      itemBuilder: (context, i) =>
                          _LineItemRow(item: order.items[i]),
                    ),
                  ],
                ),
                16.toHeight,

                // ── Order note ─────────────────────────────────────────
                if (order.orderNote != null &&
                    order.orderNote!.isNotEmpty) ...[
                  _SectionHeader(title: 'Order Note'),
                  8.toHeight,
                  _SectionCard(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.notes_rounded,
                              size: 16, color: Colors.amber[700]),
                          SizedBoxExtension(8).toWidth,
                          Expanded(
                            child: Text(
                              order.orderNote!,
                              style: context.bodySmall?.copyWith(
                                color: context.color.secondaryContrastColor
                                    .withOpacity(0.7),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  16.toHeight,
                ],

                // ── Price summary ──────────────────────────────────────
                _SectionHeader(title: 'Payment Summary'),
                8.toHeight,
                _SectionCard(
                  children: [
                    _PriceRow(label: 'Sub Total', value: order.subTotal),
                    if (order.tax > 0) ...[
                      8.toHeight,
                      _PriceRow(label: 'Tax', value: order.tax),
                    ],
                    if (order.deliveryCharge > 0) ...[
                      8.toHeight,
                      _PriceRow(
                          label: 'Delivery Charge',
                          value: order.deliveryCharge),
                    ],
                    if (order.couponAmount > 0) ...[
                      8.toHeight,
                      _PriceRow(
                        label: 'Coupon${order.couponCode != null ? ' (${order.couponCode})' : ''}',
                        value: -order.couponAmount,
                        color: Colors.green,
                      ),
                    ],
                    12.toHeight,
                    Divider(color: Colors.grey.withOpacity(0.15), height: 1),
                    12.toHeight,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: context.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${order.total}',
                          style: context.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                32.toHeight,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.bodyMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: context.color.secondaryContrastColor.withOpacity(0.5),
        fontSize: 12,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const _SectionCard({required this.children, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.color.accentContrastColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _IconRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _IconRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        SizedBoxExtension(8).toWidth,
        Text(
          '$label:',
          style: context.bodySmall?.copyWith(color: Colors.grey[500]),
        ),
        SizedBoxExtension(8).toWidth,
        Expanded(
          child: Text(
            value,
            style: context.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.color.primaryContrastColor,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _LabelValue extends StatelessWidget {
  final IconData icon;
  final String value;

  const _LabelValue({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.grey[400]),
        SizedBoxExtension(5).toWidth,
        Expanded(
          child: Text(
            value,
            style:
                context.bodySmall?.copyWith(color: Colors.grey[500]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _LineItemRow extends StatelessWidget {
  final FranchiseOrderLineItem item;
  const _LineItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final isProduct = item.type == 'product';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Type icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isProduct
                  ? Colors.purple.withOpacity(0.1)
                  : primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isProduct
                  ? Icons.inventory_2_outlined
                  : Icons.build_circle_outlined,
              size: 18,
              color: isProduct ? Colors.purple : primaryColor,
            ),
          ),
          SizedBoxExtension(12).toWidth,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: context.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                4.toHeight,
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isProduct
                            ? Colors.purple.withOpacity(0.08)
                            : primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isProduct ? 'Product' : 'Service',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isProduct ? Colors.purple : primaryColor,
                        ),
                      ),
                    ),
                    SizedBoxExtension(8).toWidth,
                    Text(
                      'Qty: ${item.quantity}',
                      style: context.bodySmall
                          ?.copyWith(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${item.total}',
                style: context.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.color.primaryContrastColor,
                ),
              ),
              4.toHeight,
              Text(
                '₹${item.price} × ${item.quantity}',
                style: context.bodySmall?.copyWith(
                  color: Colors.grey[400],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final num value;
  final Color? color;

  const _PriceRow({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final isNegative = value < 0;
    final displayValue = isNegative ? -value : value;
    final displayColor = color ??
        context.color.secondaryContrastColor.withOpacity(0.7);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.bodySmall?.copyWith(color: Colors.grey[500]),
        ),
        Text(
          '${isNegative ? '-' : ''}₹$displayValue',
          style: context.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: displayColor,
          ),
        ),
      ],
    );
  }
}

class _WhiteBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _WhiteBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBoxExtension(6).toWidth,
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton / Error ──────────────────────────────────────────────────────────

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 130,
          pinned: true,
          backgroundColor: primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: List.generate(
                5,
                (i) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  height: i == 0 ? 80 : 120,
                  decoration: BoxDecoration(
                    color: context.color.mutedContrastColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailError extends StatelessWidget {
  final VoidCallback onRetry;
  const _DetailError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: primaryColor),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 64, color: Colors.grey[300]),
            16.toHeight,
            Text('Failed to load order details',
                style: context.bodyMedium?.copyWith(color: Colors.grey[500])),
            16.toHeight,
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Width extension ───────────────────────────────────────────────────────────
extension _WidthExt on int {
  Widget get toWidth => SizedBox(width: toDouble());
}