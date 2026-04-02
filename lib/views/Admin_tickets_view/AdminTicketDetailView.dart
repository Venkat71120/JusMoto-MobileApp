import 'dart:io';

import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/models/admin_models/admin_ticket_model.dart';
import 'package:car_service/services/admin_services/AdminTicketsService.dart';
import 'package:car_service/services/socket_service.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/utils/components/image_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminTicketDetailView extends StatefulWidget {
  final int ticketId;
  const AdminTicketDetailView({super.key, required this.ticketId});

  @override
  State<AdminTicketDetailView> createState() => _AdminTicketDetailViewState();
}

class _AdminTicketDetailViewState extends State<AdminTicketDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ts = Provider.of<AdminTicketsService>(context, listen: false);
      final socket = Provider.of<SocketService>(context, listen: false);
      ts.fetchTicketDetail(widget.ticketId).then((_) {
        ts.joinTicketChat(socket, widget.ticketId);
      });
      ts.fetchFranchiseList();
    });
  }

  @override
  void dispose() {
    Provider.of<AdminTicketsService>(context, listen: false).leaveTicketChat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminTicketsService>(
      builder: (context, ts, _) {
        if (ts.isLoadingDetail && ts.ticketDetail == null) {
          return _Skeleton();
        }
        if (ts.hasDetailError || ts.ticketDetail == null) {
          return _Error(onRetry: () => ts.fetchTicketDetail(widget.ticketId));
        }
        return _Content(detail: ts.ticketDetail!, service: ts);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONTENT
// ─────────────────────────────────────────────────────────────────────────────

class _Content extends StatelessWidget {
  final AdminTicketDetailModel detail;
  final AdminTicketsService service;
  const _Content({required this.detail, required this.service});

  Color _priorityColor(String p) {
    switch (p.toLowerCase()) {
      case 'urgent': return Colors.red;
      case 'high': return Colors.orange;
      case 'normal': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticket = detail.ticket;

    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context, ticket),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Quick Actions ─────────────────────────
                        _QuickAction(
                          label: 'Update Status',
                          icon: Icons.sync_rounded,
                          color: primaryColor,
                          ticket: ticket,
                          service: service,
                        ),
                        20.toHeight,

                        // ── Ticket Info ───────────────────────────
                        _buildInfoCard(context, ticket),
                        16.toHeight,

                        // ── Description ──��────────────────────────
                        if (ticket.description != null &&
                            ticket.description!.trim().isNotEmpty) ...[
                          _buildDescriptionCard(context, ticket),
                          16.toHeight,
                        ],

                        // ── Customer ──────────────────────────────
                        _buildCustomerCard(context, ticket),
                        16.toHeight,

                        // ── Franchise Assignment ──────────────────
                        _FranchiseSection(detail: detail, service: service),
                        16.toHeight,

                        // ── Linked Order ──────────────────────────
                        if (detail.serviceRequest != null) ...[
                          _buildLinkedOrder(context, detail.serviceRequest!),
                          16.toHeight,
                        ],

                        // ── Conversation ──────────────────────────
                        _SectionTitle(
                            icon: Icons.forum_rounded,
                            title: 'Conversation'),
                        8.toHeight,
                      ],
                    ),
                  ),
                ),

                // ── Messages ──────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: detail.messages.isEmpty
                      ? SliverToBoxAdapter(
                          child: _GlassCard(
                            context: context,
                            child: Column(
                              children: [
                                20.toHeight,
                                Icon(Icons.chat_bubble_outline_rounded,
                                    size: 36,
                                    color: context.color.tertiaryContrastColo),
                                8.toHeight,
                                Text('No messages yet',
                                    style: context.bodySmall?.copyWith(
                                        color: context
                                            .color.tertiaryContrastColo)),
                                20.toHeight,
                              ],
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => _ChatBubble(
                                message: detail.messages[i]),
                            childCount: detail.messages.length,
                          ),
                        ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
              ],
            ),
          ),

          // ── Reply Bar ───────────────────────────────────────────
          _ReplyBar(ticketId: detail.ticket.id),
        ],
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context, AdminTicketDetail ticket) {
    final pColor = _priorityColor(ticket.priority);
    return SliverAppBar(
      expandedHeight: 170,
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
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    ticket.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  10.toHeight,
                  Row(
                    children: [
                      _WhiteBadge(
                        label: ticket.status.toUpperCase(),
                        dotColor: ticket.status == 'open'
                            ? Colors.greenAccent
                            : ticket.status == 'in_progress'
                                ? Colors.amber
                                : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      _WhiteBadge(
                        label: ticket.priority.toUpperCase(),
                        dotColor: pColor,
                      ),
                      if (ticket.departmentName != null) ...[
                        const SizedBox(width: 8),
                        _WhiteBadge(
                          label: ticket.departmentName!,
                          dotColor: Colors.white60,
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
    );
  }

  // ── Info Card ──────────────────────────────────────────────────────────
  Widget _buildInfoCard(BuildContext context, AdminTicketDetail ticket) {
    return _GlassCard(
      context: context,
      child: Column(
        children: [
          _InfoTile(
            context: context,
            icon: Icons.tag_rounded,
            iconColor: primaryColor,
            label: 'Ticket ID',
            value: '#${ticket.id}',
          ),
          _divider(context),
          _InfoTile(
            context: context,
            icon: Icons.calendar_today_rounded,
            iconColor: Colors.blue,
            label: 'Created',
            value: ticket.createdAt.toOrderTime,
          ),
          _divider(context),
          _InfoTile(
            context: context,
            icon: Icons.update_rounded,
            iconColor: Colors.orange,
            label: 'Updated',
            value: ticket.updatedAt.toOrderTime,
          ),
          if (ticket.orderId != null) ...[
            _divider(context),
            _InfoTile(
              context: context,
              icon: Icons.receipt_outlined,
              iconColor: Colors.teal,
              label: 'Order ID',
              value: '#${ticket.orderId}',
            ),
          ],
        ],
      ),
    );
  }

  // ── Description ────────────────────────────────────────────────────────
  Widget _buildDescriptionCard(
      BuildContext context, AdminTicketDetail ticket) {
    return _GlassCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
              icon: Icons.description_rounded, title: 'Description'),
          10.toHeight,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.color.mutedContrastColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              ticket.description!.trim(),
              style: context.bodySmall?.copyWith(
                color: context.color.secondaryContrastColor,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Customer Card ──────────────────────────────────────────────────────
  Widget _buildCustomerCard(
      BuildContext context, AdminTicketDetail ticket) {
    return _GlassCard(
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
                    ticket.customer.name.isNotEmpty
                        ? ticket.customer.name[0].toUpperCase()
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
                      ticket.customer.name,
                      style: context.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (ticket.customer.email != null) ...[
                      3.toHeight,
                      _SmallLabel(
                          icon: Icons.email_outlined,
                          value: ticket.customer.email!),
                    ],
                    if (ticket.customer.phone != null) ...[
                      3.toHeight,
                      _SmallLabel(
                          icon: Icons.phone_outlined,
                          value: ticket.customer.phone!),
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

  // ── Linked Order ───────────────────────────────────────────────────────
  Widget _buildLinkedOrder(
      BuildContext context, AdminTicketServiceRequest sr) {
    Color statusColor;
    switch (sr.statusCode) {
      case 0: statusColor = Colors.orange; break;
      case 1: statusColor = Colors.blue; break;
      case 2: statusColor = Colors.green; break;
      case 3: statusColor = Colors.teal; break;
      case 4: statusColor = Colors.red; break;
      default: statusColor = Colors.grey;
    }

    return _GlassCard(
      context: context,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                _SectionTitle(
                    icon: Icons.receipt_long_rounded,
                    title: 'Linked Order'),
                const Spacer(),
                _SmallBadge(label: sr.status, color: statusColor),
                const SizedBox(width: 6),
                _SmallBadge(
                  label: sr.paymentStatus,
                  color: sr.paymentStatus == 'Paid'
                      ? Colors.green
                      : Colors.red,
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.receipt_outlined,
                      size: 18, color: primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${sr.invoiceNumber}',
                        style: context.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                      3.toHeight,
                      Text(
                        sr.createdAt.toOrderTime,
                        style: context.bodySmall?.copyWith(
                            color: context.color.tertiaryContrastColo,
                            fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\u20B9${sr.total}',
                  style: context.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) => Divider(
      height: 1,
      thickness: 0.5,
      color: context.color.primaryBorderColor.withOpacity(0.5));
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK ACTION BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final AdminTicketDetail ticket;
  final AdminTicketsService service;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.ticket,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showSheet(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    final statuses = [
      {'val': 'open', 'label': 'Open', 'icon': Icons.lock_open_rounded, 'color': Colors.green},
      {'val': 'in_progress', 'label': 'In Progress', 'icon': Icons.autorenew_rounded, 'color': Colors.orange},
      {'val': 'closed', 'label': 'Closed', 'icon': Icons.lock_rounded, 'color': Colors.grey},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: context.color.accentContrastColor,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Update Ticket Status',
                  style: context.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
            ),
            ...statuses.map((s) {
              final isCurrent = ticket.status == s['val'];
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
                title: Text(s['label'] as String,
                    style: TextStyle(
                        fontWeight: isCurrent
                            ? FontWeight.w700
                            : FontWeight.w500)),
                trailing: isCurrent
                    ? Icon(Icons.check_circle_rounded,
                        color: primaryColor, size: 22)
                    : null,
                onTap: isCurrent
                    ? null
                    : () {
                        Navigator.pop(context);
                        service.updateTicketStatusFromDetail(
                            ticket.id, s['val'] as String);
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
// CHAT BUBBLE — admin (red/right), franchise (teal/left), customer (card/left)
// ─────────────────────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final AdminTicketMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isAdmin = message.senderType == 'admin';
    final isFranchise = message.senderType == 'franchise';
    final isRight = isAdmin;

    // Colors per sender
    final Color bgColor;
    final Color textColor;
    final Color timeColor;
    final Color labelColor;
    final String senderLabel;

    if (isAdmin) {
      bgColor = primaryColor;
      textColor = Colors.white;
      timeColor = Colors.white60;
      labelColor = Colors.white70;
      senderLabel = 'You${message.senderName != null ? ' (${message.senderName})' : ''}';
    } else if (isFranchise) {
      bgColor = Colors.teal.withOpacity(0.08);
      textColor = context.color.primaryContrastColor;
      timeColor = context.color.tertiaryContrastColo;
      labelColor = Colors.teal;
      senderLabel = 'Franchise${message.senderName != null ? ' - ${message.senderName}' : ''}';
    } else {
      bgColor = context.color.accentContrastColor;
      textColor = context.color.primaryContrastColor;
      timeColor = context.color.tertiaryContrastColo;
      labelColor = primaryColor;
      senderLabel = 'Customer${message.senderName != null ? ' - ${message.senderName}' : ''}';
    }

    return Align(
      alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isRight ? 14 : 2),
            bottomRight: Radius.circular(isRight ? 2 : 14),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: (isFranchise || !isAdmin)
              ? Border.all(
                  color: isFranchise
                      ? Colors.teal.withOpacity(0.15)
                      : context.color.primaryBorderColor.withOpacity(0.5))
              : null,
        ),
        child: Column(
          crossAxisAlignment:
              isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Sender label
            Text(
              senderLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: labelColor,
              ),
            ),
            4.toHeight,
            // Message
            if (message.message.trim().isNotEmpty)
              Text(
                message.message.trim(),
                style: context.bodySmall
                    ?.copyWith(color: textColor, height: 1.5),
              ),
            // Attachment
            if (message.attachment != null &&
                message.attachment!.isNotEmpty) ...[
              8.toHeight,
              GestureDetector(
                onTap: () => context
                    .toPage(ImageView(message.attachment!.toImageUrl)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: message.attachment!.toImageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                        height: 160,
                        color: Colors.black12,
                        child: const Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2))),
                    errorWidget: (_, __, ___) => Container(
                        height: 160,
                        color: Colors.black12,
                        child: const Icon(Icons.broken_image_outlined,
                            color: Colors.white24)),
                  ),
                ),
              ),
            ],
            4.toHeight,
            Text(
              message.createdAt.toOrderTime,
              style: TextStyle(color: timeColor, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REPLY BAR
// ─────────────────────────────────────────────────────────────────────────────

class _ReplyBar extends StatefulWidget {
  final int ticketId;
  const _ReplyBar({required this.ticketId});

  @override
  State<_ReplyBar> createState() => _ReplyBarState();
}

class _ReplyBarState extends State<_ReplyBar> {
  final _ctrl = TextEditingController();
  bool _sending = false;
  File? _file;

  void _pick() async {
    try {
      final r = await FilePicker.platform
          .pickFiles(type: FileType.image, allowMultiple: false);
      if (r != null && r.files.single.path != null) {
        setState(() => _file = File(r.files.single.path!));
      }
    } catch (_) {}
  }

  void _send() async {
    final msg = _ctrl.text.trim();
    if (msg.isEmpty && _file == null) return;

    setState(() => _sending = true);
    final ok = await Provider.of<AdminTicketsService>(context, listen: false)
        .sendReply(widget.ticketId,
            message: msg.isEmpty ? ' ' : msg, filePath: _file?.path);

    if (mounted) {
      if (ok) {
        _ctrl.clear();
        setState(() => _file = null);
      }
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 6,
        bottom: MediaQuery.of(context).padding.bottom + 6,
      ),
      decoration: BoxDecoration(
        color: context.color.accentContrastColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_file != null)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_file!,
                        height: 48, width: 48, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_file!.path.split('/').last,
                        style: context.bodySmall
                            ?.copyWith(color: Colors.grey[500]),
                        overflow: TextOverflow.ellipsis),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _file = null),
                    child: const Icon(Icons.close_rounded,
                        size: 18, color: Colors.red),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.add_photo_alternate_outlined,
                    color: context.color.tertiaryContrastColo, size: 22),
                onPressed: _sending ? null : _pick,
              ),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle:
                        context.bodySmall?.copyWith(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  style: context.bodySmall,
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                ),
              ),
              _sending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : IconButton(
                      icon: Icon(Icons.send_rounded, color: primaryColor),
                      onPressed: _send,
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FRANCHISE SECTION (matches order detail pattern)
// ─────────────────────────────────────────────────────────────────────────────

class _FranchiseSection extends StatelessWidget {
  final AdminTicketDetailModel detail;
  final AdminTicketsService service;
  const _FranchiseSection({required this.detail, required this.service});

  @override
  Widget build(BuildContext context) {
    final assigned = detail.franchise;

    return _GlassCard(
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
                    color:
                        context.color.primarySuccessColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('ASSIGNED',
                      style: TextStyle(
                          color: context.color.primarySuccessColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w800)),
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
                        Text(assigned.name,
                            style: context.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
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
                    onTap: () => _showSheet(context),
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
              onTap: () => _showSheet(context),
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
                    Text('Tap to assign a franchise',
                        style: TextStyle(
                            color: primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    3.toHeight,
                    Text('Select a franchise head for this ticket',
                        style: context.bodySmall?.copyWith(
                            color: context.color.tertiaryContrastColo,
                            fontSize: 11)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSheet(BuildContext context) {
    final franchises = service.franchiseList;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        builder: (ctx, scroll) => Container(
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
                child: Text('Assign Franchise Head',
                    style: context.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ),
              if (service.isLoadingFranchises)
                Padding(
                    padding: const EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: primaryColor))
              else if (franchises.isEmpty)
                Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text('No franchises available',
                        style: context.bodySmall?.copyWith(
                            color: context.color.tertiaryContrastColo)))
              else
                Expanded(
                  child: ListView.builder(
                    controller: scroll,
                    itemCount: franchises.length,
                    itemBuilder: (_, i) {
                      final f = franchises[i];
                      final isAssigned = detail.franchise?.id == f.id;
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isAssigned
                                ? primaryColor.withOpacity(0.12)
                                : context.color.mutedContrastColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.storefront_rounded,
                              color: isAssigned
                                  ? primaryColor
                                  : context.color.tertiaryContrastColo,
                              size: 20),
                        ),
                        title: Text(f.name,
                            style: TextStyle(
                                fontWeight: isAssigned
                                    ? FontWeight.w700
                                    : FontWeight.w500)),
                        subtitle: f.location != null
                            ? Text(f.location!,
                                style: context.bodySmall?.copyWith(
                                    color:
                                        context.color.tertiaryContrastColo),
                                overflow: TextOverflow.ellipsis)
                            : null,
                        trailing: isAssigned
                            ? Icon(Icons.check_circle_rounded,
                                color: primaryColor, size: 22)
                            : null,
                        onTap: isAssigned
                            ? null
                            : () {
                                Navigator.pop(context);
                                service.assignFranchise(
                                    detail.ticket.id, f.id);
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
// REUSABLE WIDGETS (matching order detail page)
// ─────────────────────────────────────────────────────────────────────────────

Widget _sheetHandle() => Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
          color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
    );

class _GlassCard extends StatelessWidget {
  final BuildContext context;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const _GlassCard(
      {required this.context, required this.child, this.padding});

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
        Text(title,
            style: context.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.3,
                color: context.color.primaryContrastColor)),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final BuildContext context;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  const _InfoTile(
      {required this.context,
      required this.icon,
      required this.iconColor,
      required this.label,
      required this.value});

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
          Text(label,
              style: context.bodySmall
                  ?.copyWith(color: context.color.tertiaryContrastColo)),
          const Spacer(),
          Text(value,
              style: context.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.color.primaryContrastColor)),
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
            child: Text(value,
                style: context.bodySmall?.copyWith(
                    color: context.color.tertiaryContrastColo),
                overflow: TextOverflow.ellipsis)),
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
              decoration:
                  BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
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
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SKELETON & ERROR
// ─────────────────────────────────────────────────────────────────────────────

class _Skeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 170,
            pinned: true,
            backgroundColor: primaryColor,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.8)]),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Action skeleton
                  Container(
                    height: 48,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: context.color.mutedContrastColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  ...List.generate(
                    4,
                    (i) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      height: i == 3 ? 200 : 90,
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
      ),
    );
  }
}

class _Error extends StatelessWidget {
  final VoidCallback onRetry;
  const _Error({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
          backgroundColor: primaryColor,
          iconTheme: const IconThemeData(color: Colors.white)),
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
            Text('Failed to load ticket',
                style:
                    context.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            8.toHeight,
            Text('Please check your connection and try again',
                style: context.bodySmall
                    ?.copyWith(color: context.color.tertiaryContrastColo)),
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
