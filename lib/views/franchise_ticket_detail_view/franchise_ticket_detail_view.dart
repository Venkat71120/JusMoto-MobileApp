// ─────────────────────────────────────────────────────────────────────────────
// VIEW: franchise_ticket_detail_view.dart
// Location: lib/views/franchise_services_view/franchise_ticket_detail_view.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/models/franchise_models/franchise_ticket_model.dart';
import 'package:car_service/services/Franchise_dashboard_Services/franchise_tickets_service.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/utils/components/image_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class FranchiseTicketDetailView extends StatefulWidget {
  final int ticketId;
  const FranchiseTicketDetailView({super.key, required this.ticketId});

  @override
  State<FranchiseTicketDetailView> createState() =>
      _FranchiseTicketDetailViewState();
}

class _FranchiseTicketDetailViewState
    extends State<FranchiseTicketDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FranchiseTicketsService>(context, listen: false)
          .fetchTicketDetail(widget.ticketId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FranchiseTicketsService>(
      builder: (context, ts, _) {
        if (ts.isLoadingDetail) {
          return const _DetailSkeleton();
        }
        if (ts.hasDetailError || ts.ticketDetail == null) {
          return _DetailError(
              onRetry: () => ts.fetchTicketDetail(widget.ticketId));
        }
        return _DetailContent(detail: ts.ticketDetail!);
      },
    );
  }
}

// ── Main Content ──────────────────────────────────────────────────────────────

class _DetailContent extends StatelessWidget {
  final FranchiseTicketDetailModel detail;
  const _DetailContent({required this.detail});

  Color _priorityColor(String p) {
    switch (p.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'normal':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticket = detail.ticket;
    final pColor = _priorityColor(ticket.priority);
    final isOpen = ticket.status.toLowerCase() == 'open';

    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── App bar with gradient ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 150,
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
                          ticket.title,
                          style: context.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        8.toHeight,
                        Row(
                          children: [
                            _WhiteBadge(
                              label: ticket.status.toUpperCase(),
                              dotColor: isOpen
                                  ? Colors.greenAccent
                                  : Colors.white54,
                            ),
                            SizedBoxExtension(8).toWidth,
                            _WhiteBadge(
                              label: ticket.priority.toUpperCase(),
                              dotColor: pColor,
                            ),
                            if (ticket.department != null) ...[
                              SizedBoxExtension(8).toWidth,
                              _WhiteBadge(
                                label: ticket.department!.name,
                                dotColor: Colors.white54,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // ── Status update actions ──────────────────────────────
            actions: [
              _StatusPopup(ticket: ticket),
              SizedBoxExtension(8).toWidth,
            ],
          ),

          // ── Body ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Ticket meta ──────────────────────────────────
                  _SectionCard(
                    children: [
                      _MetaRow(
                        icon: Icons.tag_outlined,
                        label: 'Ticket ID',
                        value: '#${ticket.id}',
                      ),
                      8.toHeight,
                      _MetaRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Created',
                        value: _formatDateTime(ticket.createdAt),
                      ),
                      8.toHeight,
                      _MetaRow(
                        icon: Icons.update_outlined,
                        label: 'Updated',
                        value: _formatDateTime(ticket.updatedAt),
                      ),
                      if (ticket.orderId != null) ...[
                        8.toHeight,
                        _MetaRow(
                          icon: Icons.receipt_outlined,
                          label: 'Order ID',
                          value: '#${ticket.orderId}',
                        ),
                      ],
                    ],
                  ),
                  16.toHeight,

                  // ── Description ──────────────────────────────────
                  if (ticket.description != null &&
                      ticket.description!.trim().isNotEmpty) ...[
                    _SectionHeader(title: 'Description'),
                    8.toHeight,
                    _SectionCard(
                      children: [
                        Text(
                          ticket.description!.trim(),
                          style: context.bodySmall?.copyWith(
                            color: context.color.secondaryContrastColor
                                .withOpacity(0.7),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                    16.toHeight,
                  ],

                  // ── Customer ─────────────────────────────────────
                  _SectionHeader(title: 'Customer'),
                  8.toHeight,
                  _SectionCard(
                    children: [
                      Row(
                        children: [
                          // Avatar
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                ticket.customer.name.isNotEmpty
                                    ? ticket.customer.name[0].toUpperCase()
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
                                  ticket.customer.name,
                                  style: context.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (ticket.customer.email != null) ...[
                                  4.toHeight,
                                  _ContactRow(
                                    icon: Icons.email_outlined,
                                    value: ticket.customer.email!,
                                  ),
                                ],
                                if (ticket.customer.phone != null) ...[
                                  4.toHeight,
                                  _ContactRow(
                                    icon: Icons.phone_outlined,
                                    value: ticket.customer.phone!,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  16.toHeight,

                  // ── Linked service request ────────────────────────
                  if (detail.serviceRequest != null) ...[
                    _SectionHeader(title: 'Linked Order'),
                    8.toHeight,
                    _LinkedOrderCard(sr: detail.serviceRequest!),
                    16.toHeight,
                  ],

                  // ── Conversation ─────────────────────────────────
                  _SectionHeader(title: 'Conversation'),
                  8.toHeight,
                  ...detail.messages.map((m) => _MessageBubble(message: m)),
                  20.toHeight,
                  _ReplyInput(ticketId: ticket.id),
                  40.toHeight,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Linked Order Card ─────────────────────────────────────────────────────────

class _LinkedOrderCard extends StatelessWidget {
  final FranchiseTicketServiceRequest sr;
  const _LinkedOrderCard({required this.sr});

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

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(sr.statusCode);

    return _SectionCard(
      padding: EdgeInsets.zero,
      children: [
        // Header strip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.06),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 16, color: primaryColor),
              SizedBoxExtension(8).toWidth,
              Expanded(
                child: Text(
                  '#${sr.invoiceNumber}',
                  style: context.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              _SmallBadge(label: sr.status, color: statusColor),
              SizedBoxExtension(8).toWidth,
              _SmallBadge(
                label: sr.paymentStatus,
                color: sr.paymentStatus.toLowerCase() == 'paid'
                    ? Colors.green
                    : Colors.red,
              ),
            ],
          ),
        ),

        // Meta
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MetaRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value: _formatDateTime(sr.date)),
                  ),
                  SizedBoxExtension(12).toWidth,
                  Expanded(
                    child: _MetaRow(
                        icon: Icons.access_time_outlined,
                        label: 'Time',
                        value: sr.schedule),
                  ),
                ],
              ),
              if (sr.outlet != null) ...[
                8.toHeight,
                _MetaRow(
                  icon: Icons.store_outlined,
                  label: 'Outlet',
                  value: sr.outlet!.name +
                      (sr.outlet!.address != null
                          ? ', ${sr.outlet!.address}'
                          : ''),
                ),
              ],
              12.toHeight,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total',
                      style: context.bodySmall
                          ?.copyWith(color: Colors.grey[500])),
                  Text(
                    '₹${sr.total}',
                    style: context.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Message Bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final FranchiseTicketMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isAdmin = message.type == 'admin';
    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isAdmin ? primaryColor : context.color.accentContrastColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isAdmin ? 16 : 0),
            bottomRight: Radius.circular(isAdmin ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.message.trim(),
              style: context.bodySmall?.copyWith(
                color: isAdmin ? Colors.white : context.color.primaryContrastColor,
                height: 1.4,
              ),
            ),
            if (message.attachment != null && message.attachment!.isNotEmpty) ...[
              10.toHeight,
              GestureDetector(
                onTap: () => context.toPage(ImageView(message.attachment!.toImageUrl)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: message.attachment!.toImageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 180,
                      color: Colors.black12,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 180,
                      color: Colors.black12,
                      child: const Icon(Icons.broken_image_outlined, color: Colors.white24),
                    ),
                  ),
                ),
              ),
            ],
            4.toHeight,
            Text(
              _formatDateTime(message.createdAt),
              style: TextStyle(
                color: isAdmin ? Colors.white60 : Colors.grey[400],
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reply Input ───────────────────────────────────────────────────────────────

class _ReplyInput extends StatefulWidget {
  final int ticketId;
  const _ReplyInput({required this.ticketId});

  @override
  State<_ReplyInput> createState() => _ReplyInputState();
}

class _ReplyInputState extends State<_ReplyInput> {
  final _controller = TextEditingController();
  bool _isSending = false;

  void _send() async {
    final msg = _controller.text.trim();
    if (msg.isEmpty) return;

    setState(() => _isSending = true);
    final success = await Provider.of<FranchiseTicketsService>(context, listen: false)
        .sendServiceRequestReply(widget.ticketId, message: msg);
    
    if (mounted) {
      if (success) _controller.clear();
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Type your reply...',
                  hintStyle: context.bodySmall?.copyWith(color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                style: context.bodySmall,
                maxLines: 4,
                minLines: 1,
              ),
            ),
            _isSending
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.send_rounded, color: primaryColor),
                    onPressed: _send,
                  ),
          ],
        ),
      ],
    );
  }
}

// ── Status Popup ─────────────────────────────────────────────────────────────

class _StatusPopup extends StatelessWidget {
  final FranchiseTicketDetail ticket;
  const _StatusPopup({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.4)),
        ),
        child: const Text(
          'Update Status',
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      onSelected: (val) {
        Provider.of<FranchiseTicketsService>(context, listen: false)
            .updateServiceRequestStatus(ticket.id, val);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'open', child: Text('Open')),
        const PopupMenuItem(value: 'in_progress', child: Text('In Progress')),
        const PopupMenuItem(value: 'closed', child: Text('Closed')),
      ],
    );
  }
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

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

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.grey[400]),
        SizedBoxExtension(6).toWidth,
        Text('$label:',
            style: context.bodySmall?.copyWith(color: Colors.grey[500])),
        SizedBoxExtension(6).toWidth,
        Expanded(
          child: Text(
            value.toString(),
            style: context.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.color.primaryContrastColor,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _ContactRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.grey[400]),
        SizedBoxExtension(5).toWidth,
        Expanded(
          child: Text(
            value,
            style: context.bodySmall?.copyWith(color: Colors.grey[500]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration:
                BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          SizedBoxExtension(5).toWidth,
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _SmallBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ── Skeleton & Error ──────────────────────────────────────────────────────────

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
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
                    height: i == 0 ? 80 : i == 2 ? 140 : 120,
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
      ),
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
            Text('Failed to load ticket',
                style:
                    context.bodyMedium?.copyWith(color: Colors.grey[500])),
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

String _formatDateTime(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return 'N/A';
  try {
    final date = DateTime.parse(dateStr).toLocal();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return timeago.format(date);
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE, h:mm a').format(date);
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  } catch (e) {
    return dateStr;
  }
}

extension _WidthExt on int {
  Widget get toWidth => SizedBox(width: toDouble());
}