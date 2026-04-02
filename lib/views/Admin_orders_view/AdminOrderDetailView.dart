import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/models/admin_models/admin_order_model.dart';
import 'package:car_service/services/admin_services/AdminOrdersService.dart';
import 'package:car_service/utils/components/image_view.dart';
import '../../utils/components/custom_network_image.dart';
import '../../helper/extension/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminOrderDetailView extends StatefulWidget {
  final int orderId;
  const AdminOrderDetailView({super.key, required this.orderId});

  @override
  State<AdminOrderDetailView> createState() => _AdminOrderDetailViewState();
}

class _AdminOrderDetailViewState extends State<AdminOrderDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final os = Provider.of<AdminOrdersService>(context, listen: false);
      os.fetchOrderDetail(widget.orderId);
      os.fetchFranchiseList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminOrdersService>(
      builder: (context, os, _) {
        return Scaffold(
          backgroundColor: context.color.backgroundColor,
          body: os.isLoadingDetail
              ? const _DetailSkeleton()
              : os.hasDetailError || os.orderDetail == null
                  ? _DetailError(
                      onRetry: () => os.fetchOrderDetail(widget.orderId))
                  : _DetailBody(order: os.orderDetail!, service: os),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN DETAIL BODY
// ─────────────────────────────────────────────────────────────────────────────

class _DetailBody extends StatelessWidget {
  final AdminOrderDetailModel order;
  final AdminOrdersService service;

  const _DetailBody({required this.order, required this.service});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(context),
        SliverToBoxAdapter(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Quick action buttons ────────────────────────
                    _QuickActions(order: order, service: service),
                    20.toHeight,

                    // ── Order info ──────────────────────────────────
                    _buildOrderInfoCard(context),
                    16.toHeight,

                    // ── Customer info ───────────────────────────────
                    _buildCustomerCard(context),
                    16.toHeight,

                    // ── Franchise assignment ────────────────────────
                    _FranchiseAssignCard(order: order, service: service),
                    16.toHeight,

                    // ── Location ────────────────────────────────────
                    if (order.location?.address != null) ...[
                      _buildLocationCard(context),
                      16.toHeight,
                    ],

                    // ── Staff ───────────────────────────────────────
                    if (order.staff != null) ...[
                      _buildStaffCard(context),
                      16.toHeight,
                    ],

                    // ── Order Items ─────────────────────────────────
                    _buildItemsCard(context),
                    16.toHeight,

                    // ── Order note ──────────────────────────────────
                    if (order.orderNote != null &&
                        order.orderNote!.isNotEmpty) ...[
                      _buildNoteCard(context),
                      16.toHeight,
                    ],

                    // ── Payment summary ─────────────────────────────
                    _buildPaymentSummary(context),
                    32.toHeight,
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    final isPaid = order.paymentStatusCode == 1;
    return SliverAppBar(
      expandedHeight: 185,
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
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '#${order.invoiceNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  10.toHeight,
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 13, color: Colors.white.withOpacity(0.7)),
                      const SizedBox(width: 6),
                      Text(
                        order.createdAt.toOrderTime,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  10.toHeight,
                  Row(
                    children: [
                      _WhiteBadge(
                        label: order.status,
                        dotColor: _statusColor(order.statusCode),
                      ),
                      const SizedBox(width: 8),
                      _WhiteBadge(
                        label: order.paymentStatus,
                        dotColor: isPaid ? Colors.green : Colors.redAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Order Info Card ─────────────────────────────────────────────────────
  Widget _buildOrderInfoCard(BuildContext context) {
    return _Card(
      context: context,
      child: Column(
        children: [
          _InfoTile(
            context: context,
            icon: Icons.receipt_long_rounded,
            iconColor: primaryColor,
            label: 'Payment Method',
            value: _formatGateway(order.paymentGateway),
          ),
          _thinDivider(context),
          if (order.transactionId != null &&
              order.transactionId!.isNotEmpty) ...[
            _InfoTile(
              context: context,
              icon: Icons.tag_rounded,
              iconColor: Colors.amber[700]!,
              label: 'Transaction ID',
              value: order.transactionId!,
            ),
            _thinDivider(context),
          ],
          _InfoTile(
            context: context,
            icon: Icons.monetization_on_rounded,
            iconColor: context.color.primarySuccessColor,
            label: 'Order Total',
            value: '\u20B9${order.total}',
            valueBold: true,
          ),
        ],
      ),
    );
  }

  // ── Customer Card ──────────────────────────────────────────────────────
  Widget _buildCustomerCard(BuildContext context) {
    return _Card(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.person_rounded, title: 'Customer Details'),
          12.toHeight,
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    order.customer.name.isNotEmpty
                        ? order.customer.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customer.name,
                      style: context.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (order.customer.email != null) ...[
                      3.toHeight,
                      _SmallLabel(
                          icon: Icons.email_outlined,
                          value: order.customer.email!),
                    ],
                    if (order.customer.phone != null) ...[
                      3.toHeight,
                      _SmallLabel(
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
    );
  }

  // ── Location Card ──────────────────────────────────────────────────────
  Widget _buildLocationCard(BuildContext context) {
    return _Card(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
              icon: Icons.location_on_rounded, title: 'Service Location'),
          10.toHeight,
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: primaryColor.withOpacity(0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.pin_drop_rounded,
                      size: 16, color: primaryColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    order.location!.address!,
                    style: context.bodySmall?.copyWith(
                      color: context.color.secondaryContrastColor,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Staff Card ─────────────────────────────────────────────────────────
  Widget _buildStaffCard(BuildContext context) {
    return _Card(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
              icon: Icons.engineering_rounded, title: 'Assigned Mechanic'),
          10.toHeight,
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.color.primaryPendingColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.handyman_rounded,
                    size: 20, color: context.color.primaryPendingColor),
              ),
              const SizedBox(width: 12),
              Text(
                order.staff!.name,
                style: context.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Order Items ────────────────────────────────────────────────────────
  Widget _buildItemsCard(BuildContext context) {
    return _Card(
      context: context,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                _SectionTitle(
                    icon: Icons.build_circle_rounded,
                    title: 'Services & Products'),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${order.items.length} items',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (_, __) => Divider(
                height: 1,
                color: context.color.primaryBorderColor.withOpacity(0.5)),
            itemBuilder: (context, i) => _ItemTile(item: order.items[i]),
          ),
        ],
      ),
    );
  }

  // ── Order Note ─────────────────────────────────────────────────────────
  Widget _buildNoteCard(BuildContext context) {
    return _Card(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
              icon: Icons.sticky_note_2_rounded, title: 'Order Note'),
          10.toHeight,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.color.primaryPendingColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: context.color.primaryPendingColor.withOpacity(0.12)),
            ),
            child: Text(
              order.orderNote!,
              style: context.bodySmall?.copyWith(
                color: context.color.secondaryContrastColor,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Payment Summary ────────────────────────────────────────────────────
  Widget _buildPaymentSummary(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.account_balance_wallet_rounded,
                    size: 18, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Payment Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            16.toHeight,
            _SummaryRow(label: 'Sub Total', value: order.subTotal),
            if (order.tax > 0) ...[
              8.toHeight,
              _SummaryRow(label: 'Tax', value: order.tax),
            ],
            if (order.deliveryCharge > 0) ...[
              8.toHeight,
              _SummaryRow(
                  label: 'Delivery Charge', value: order.deliveryCharge),
            ],
            if (order.couponAmount > 0) ...[
              8.toHeight,
              _SummaryRow(
                label:
                    'Coupon${order.couponCode != null ? ' (${order.couponCode})' : ''}',
                value: -order.couponAmount,
                valueColor: Colors.greenAccent,
              ),
            ],
            16.toHeight,
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
            16.toHeight,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '\u20B9${order.total}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _thinDivider(BuildContext context) => Divider(
      height: 1,
      thickness: 0.5,
      color: context.color.primaryBorderColor.withOpacity(0.5));

  static String _formatGateway(String raw) {
    if (raw.isEmpty) return 'N/A';
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty
            ? ''
            : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK ACTIONS — Change Status, Payment Status
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  final AdminOrderDetailModel order;
  final AdminOrdersService service;

  const _QuickActions({required this.order, required this.service});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.sync_rounded,
            label: 'Update Status',
            color: primaryColor,
            onTap: () => _showStatusSheet(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: Icons.payment_rounded,
            label: 'Payment Status',
            color: order.paymentStatusCode == 1
                ? context.color.primarySuccessColor
                : context.color.primaryPendingColor,
            onTap: () => _showPaymentSheet(context),
          ),
        ),
      ],
    );
  }

  void _showStatusSheet(BuildContext context) {
    final statuses = [
      {'code': 0, 'label': 'Pending', 'icon': Icons.hourglass_empty_rounded, 'color': Colors.orange},
      {'code': 1, 'label': 'Accepted', 'icon': Icons.thumb_up_alt_rounded, 'color': Colors.blue},
      {'code': 2, 'label': 'In Progress', 'icon': Icons.autorenew_rounded, 'color': Colors.purple},
      {'code': 3, 'label': 'Completed', 'icon': Icons.check_circle_rounded, 'color': Colors.green},
      {'code': 4, 'label': 'Cancelled', 'icon': Icons.cancel_rounded, 'color': Colors.red},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: context.color.accentContrastColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Update Order Status',
                style: context.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            ...statuses.map((s) {
              final isSelected = order.statusCode == s['code'] as int;
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (s['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(s['icon'] as IconData,
                      color: s['color'] as Color, size: 20),
                ),
                title: Text(
                  s['label'] as String,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: context.color.primaryContrastColor,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded,
                        color: primaryColor, size: 22)
                    : null,
                onTap: isSelected
                    ? null
                    : () {
                        Navigator.pop(context);
                        service.updateOrderStatusFromDetail(
                            order.id, s['code'] as int);
                      },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showPaymentSheet(BuildContext context) {
    final options = [
      {'code': 0, 'label': 'Unpaid', 'icon': Icons.money_off_rounded, 'color': Colors.orange},
      {'code': 1, 'label': 'Paid', 'icon': Icons.paid_rounded, 'color': Colors.green},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: context.color.accentContrastColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Update Payment Status',
                style: context.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            ...options.map((o) {
              final isSelected = order.paymentStatusCode == o['code'] as int;
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (o['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(o['icon'] as IconData,
                      color: o['color'] as Color, size: 20),
                ),
                title: Text(
                  o['label'] as String,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: context.color.primaryContrastColor,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded,
                        color: primaryColor, size: 22)
                    : null,
                onTap: isSelected
                    ? null
                    : () {
                        Navigator.pop(context);
                        service.updatePaymentStatusFromDetail(
                            order.id, o['code'] as int);
                      },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FRANCHISE ASSIGNMENT CARD
// ─────────────────────────────────────────────────────────────────────────────

class _FranchiseAssignCard extends StatelessWidget {
  final AdminOrderDetailModel order;
  final AdminOrdersService service;

  const _FranchiseAssignCard({required this.order, required this.service});

  @override
  Widget build(BuildContext context) {
    final assigned = order.franchise;

    return _Card(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SectionTitle(
                  icon: Icons.store_rounded, title: 'Franchise Head'),
              const Spacer(),
              if (assigned != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: context.color.primarySuccessColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ASSIGNED',
                    style: TextStyle(
                      color: context.color.primarySuccessColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          12.toHeight,
          if (assigned != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.storefront_rounded,
                        color: primaryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assigned.name,
                          style: context.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (assigned.location != null) ...[
                          3.toHeight,
                          _SmallLabel(
                              icon: Icons.location_on_outlined,
                              value: assigned.location!),
                        ],
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showFranchiseSheet(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.color.mutedContrastColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.swap_horiz_rounded,
                          size: 18, color: primaryColor),
                    ),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: () => _showFranchiseSheet(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withOpacity(0.12)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add_business_rounded,
                          color: primaryColor, size: 22),
                    ),
                    8.toHeight,
                    Text(
                      'Tap to assign a franchise',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    3.toHeight,
                    Text(
                      'Select a franchise head to handle this order',
                      style: context.bodySmall?.copyWith(
                        color: context.color.tertiaryContrastColo,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFranchiseSheet(BuildContext context) {
    final franchises = service.franchiseList;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        minChildSize: 0.3,
        builder: (ctx, scrollController) => Container(
          decoration: BoxDecoration(
            color: context.color.accentContrastColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _sheetHandle(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Assign Franchise Head',
                  style: context.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              if (service.isLoadingFranchises)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: primaryColor),
                )
              else if (franchises.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.store_mall_directory_outlined,
                          size: 48, color: context.color.tertiaryContrastColo),
                      8.toHeight,
                      Text('No franchises available',
                          style: context.bodySmall?.copyWith(
                              color: context.color.tertiaryContrastColo)),
                    ],
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: franchises.length,
                    itemBuilder: (ctx2, i) {
                      final f = franchises[i];
                      final isAssigned = order.franchise?.id == f.id;
                      return ListTile(
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isAssigned
                                ? primaryColor.withOpacity(0.12)
                                : context.color.mutedContrastColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.storefront_rounded,
                            color: isAssigned
                                ? primaryColor
                                : context.color.tertiaryContrastColo,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          f.name,
                          style: TextStyle(
                            fontWeight: isAssigned
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: context.color.primaryContrastColor,
                          ),
                        ),
                        subtitle: f.location != null
                            ? Text(
                                f.location!,
                                style: context.bodySmall?.copyWith(
                                    color: context.color.tertiaryContrastColo),
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: isAssigned
                            ? Icon(Icons.check_circle_rounded,
                                color: primaryColor, size: 22)
                            : Icon(Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: context.color.primaryBorderColor),
                        onTap: isAssigned
                            ? null
                            : () {
                                Navigator.pop(ctx2);
                                service.assignFranchise(order.id, f.id);
                              },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE SUB-WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

Widget _sheetHandle() => Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );

class _Card extends StatelessWidget {
  final BuildContext context;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _Card({required this.context, required this.child, this.padding});

  @override
  Widget build(BuildContext _) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.color.accentContrastColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: context.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 0.3,
            color: context.color.primaryContrastColor,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final BuildContext context;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool valueBold;

  const _InfoTile({
    required this.context,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext _) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: context.bodySmall?.copyWith(
              color: context.color.tertiaryContrastColo,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: valueBold
                ? context.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  )
                : context.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.color.primaryContrastColor,
                  ),
          ),
        ],
      ),
    );
  }
}

class _SmallLabel extends StatelessWidget {
  final IconData icon;
  final String value;

  const _SmallLabel({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: context.color.tertiaryContrastColo),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: context.bodySmall?.copyWith(
              color: context.color.tertiaryContrastColo,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  final AdminOrderLineItem item;
  const _ItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isProduct = item.type == 'product';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          item.image != null && item.image.toString().isNotEmpty
              ? GestureDetector(
                  onTap: () => context
                      .toPage(ImageView(item.image.toString().toImageUrl)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CustomNetworkImage(
                      width: 50,
                      height: 50,
                      imageUrl: item.image.toString().toImageUrl,
                      radius: 10,
                      fit: BoxFit.cover,
                      errorWidget: _typeIcon(context, isProduct),
                    ),
                  ),
                )
              : _typeIcon(context, isProduct),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: context.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                6.toHeight,
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isProduct
                            ? Colors.purple.withOpacity(0.08)
                            : primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isProduct ? 'Product' : 'Service',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isProduct ? Colors.purple : primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.color.mutedContrastColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'x${item.quantity}',
                        style: context.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: context.color.secondaryContrastColor,
                        ),
                      ),
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
                '\u20B9${item.total}',
                style: context.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              4.toHeight,
              Text(
                '\u20B9${item.price} ea',
                style: context.bodySmall?.copyWith(
                  color: context.color.tertiaryContrastColo,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeIcon(BuildContext context, bool isProduct) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isProduct
            ? Colors.purple.withOpacity(0.08)
            : primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        isProduct ? Icons.inventory_2_rounded : Icons.build_circle_rounded,
        size: 22,
        color: isProduct ? Colors.purple : primaryColor,
      ),
    );
  }
}

class _WhiteBadge extends StatelessWidget {
  final String label;
  final Color dotColor;

  const _WhiteBadge({required this.label, required this.dotColor});

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
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final num value;
  final Color? valueColor;

  const _SummaryRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final isNegative = value < 0;
    final displayValue = isNegative ? -value : value;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
        ),
        Text(
          '${isNegative ? '- ' : ''}\u20B9$displayValue',
          style: TextStyle(
            color: valueColor ?? Colors.white.withOpacity(0.85),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SKELETON & ERROR
// ─────────────────────────────────────────────────────────────────────────────

Color _statusColor(int code) {
  switch (code) {
    case 0: return Colors.orange;
    case 1: return Colors.blue;
    case 2: return Colors.purple;
    case 3: return Colors.green;
    case 4: return Colors.red;
    default: return Colors.grey;
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 160,
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
              children: [
                Container(
                  height: 60,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: context.color.accentContrastColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: context.color.mutedContrastColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: context.color.mutedContrastColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...List.generate(
                  4,
                  (i) => Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    height: i == 2 ? 160 : 100,
                    decoration: BoxDecoration(
                      color: context.color.accentContrastColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
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
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.color.primaryWarningColor.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded,
                  size: 56, color: context.color.primaryWarningColor),
            ),
            20.toHeight,
            Text(
              'Failed to load order details',
              style: context.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            8.toHeight,
            Text(
              'Please check your connection and try again',
              style: context.bodySmall?.copyWith(
                color: context.color.tertiaryContrastColo,
              ),
            ),
            24.toHeight,
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
