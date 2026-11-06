import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/analytics_api/analytics_api.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/analytics_model.dart';
import 'package:hef/src/data/services/launch_url.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:intl/intl.dart';

class AnalyticsModalSheet extends ConsumerWidget {
  final AnalyticsModel analytic;
  final String tabBarType;
  const AnalyticsModalSheet({
    Key? key,
    required this.tabBarType,
    required this.analytic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AnalyticsApiService analyticsApiService = AnalyticsApiService();
    NavigationService navigationService = NavigationService();
    final description = (analytic.description ?? '').trim();
    final canEdit = _shouldShowActionButtons();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                height: 4,
                width: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _avatar(analytic.userImage),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              analytic.username?.trim().isNotEmpty == true
                                  ? analytic.username!
                                  : 'Member',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              analytic.title?.trim().isNotEmpty == true
                                  ? analytic.title!
                                  : '-',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 12,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (canEdit) ...[
                        const SizedBox(width: 30),
                        _editButton(navigationService),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Color(0xFF111827), size: 20),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F2F4)),
            _buildDetailRow('Request Type', analytic.type ?? ''),
            _buildDetailRow('Title', analytic.title ?? ''),
            if (analytic.date != null)
              _buildDetailRow(
                'Date',
                DateFormat('MMM d yyyy').format(analytic.date!.toLocal()),
              ),
            if (analytic.time != null && analytic.time!.trim().isNotEmpty)
              _buildDetailRow('Time', analytic.time!.trim()),
            if (analytic.amount != null)
              _buildDetailRow(
                'Amount',
                '₹${analytic.amount!.toStringAsFixed(2)}',
              ),
            if (analytic.meetingLink != null &&
                analytic.meetingLink!.trim().isNotEmpty)
              InkWell(
                onTap: () => launchURL(analytic.meetingLink ?? ''),
                child: _buildDetailRow('Meeting Link', analytic.meetingLink!),
              ),
            _buildStatusRow(analytic.status ?? ''),
            const SizedBox(height: 18),
            const Text(
              'Description',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description.isEmpty ? '-' : description,
              style: const TextStyle(
                color: Color(0xFF878C98),
                fontSize: 14,
                height: 1.35,
              ),
            ),
            if (analytic.referral?.name != '' &&
                analytic.referral?.name != null)
              const Text(
                'Referral Details:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            if (analytic.referral?.name != '' &&
                analytic.referral?.name != null)
              const SizedBox(height: 4),
            if (analytic.referral?.name != '' &&
                analytic.referral?.name != null)
              _buildDetailRow('name', analytic.referral?.name ?? ''),
            if (analytic.referral?.email != '' &&
                analytic.referral?.email != null)
              _buildDetailRow('email', analytic.referral?.email ?? ''),
            if (analytic.referral?.phone != '' &&
                analytic.referral?.phone != null)
              _buildDetailRow('phone', analytic.referral?.phone ?? ''),
            if (analytic.referral?.address != '' &&
                analytic.referral?.address != null)
              _buildDetailRow('address', analytic.referral?.address ?? ''),
            if (analytic.referral?.info != '' &&
                analytic.referral?.info != null)
              _buildDetailRow('info', analytic.referral?.info ?? ''),
            const SizedBox(height: 8),
            ..._actionButtons(analyticsApiService, navigationService, ref),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String? url) {
    const size = 44.0;
    final image = url != null && url.isNotEmpty
        ? Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _avatarFallback(),
          )
        : _avatarFallback();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(width: size, height: size, child: image),
    );
  }

  Widget _avatarFallback() {
    return const ColoredBox(
      color: Color(0xFFF1F2F4),
      child: Icon(Icons.person, color: Color(0xFFB0B4BA), size: 26),
    );
  }

  Widget _editButton(NavigationService navigationService) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFF86808),
        side: const BorderSide(color: Color(0xFFF6C48A)),
        backgroundColor: const Color(0xFFFFFAF3),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        minimumSize: const Size(0, 26),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const StadiumBorder(),
      ),
      onPressed: () {
        navigationService.pop();
        navigationService.pushNamed(
          'EditAnalyticRequest',
          arguments: {
            'analytic': analytic,
            'isReceived': tabBarType == 'received',
          },
        );
      },
      icon: const Icon(Icons.edit_outlined, size: 13),
      label: const Text(
        'Edit',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final shown = value.trim().isEmpty ? '-' : value;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  shown,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1F2534),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (shown != '-')
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: shown));
                    SnackbarService().showSnackBar('Copied to clipboard');
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.copy_outlined,
                      size: 16,
                      color: Color(0xFFC4C8D0),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F2F4)),
      ],
    );
  }

  Widget _buildStatusRow(String raw) {
    final style = _statusStyle(raw);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              const Text(
                'Status',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (style.label.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                    color: style.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    style.label,
                    style: TextStyle(
                      color: style.foreground,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }

  _StatusStyle _statusStyle(String raw) {
    final value = raw.trim().toLowerCase();
    if (value.isEmpty) {
      return const _StatusStyle('', Colors.transparent, Colors.transparent);
    }
    final label = value
        .split(RegExp(r'[_\s]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
    switch (value) {
      case 'accepted':
      case 'completed':
        return _StatusStyle(
          label,
          const Color(0xFFD0F8E4),
          const Color(0xFF188464),
        );
      case 'pending':
        return _StatusStyle(
          label,
          const Color(0xFFFCF8E0),
          const Color(0xFFA89858),
        );
      case 'rejected':
        return _StatusStyle(
          label,
          const Color(0xFFFDECEC),
          const Color(0xFFE15B5B),
        );
      case 'meeting_scheduled':
        return const _StatusStyle(
          'Meeting Scheduled',
          Color(0xFFE8F1FC),
          Color(0xFF2B74E1),
        );
      default:
        return _StatusStyle(
          label,
          const Color(0xFFF3F4F6),
          const Color(0xFF8A8F98),
        );
    }
  }

  // Helper method to determine if action buttons should be shown
  bool _shouldShowActionButtons() {
    // Show edit/cancel buttons for sent requests or if user is the owner
    return (tabBarType == 'sent' || analytic.user_id == id) &&
        analytic.status != 'completed' &&
        analytic.status != 'rejected';
  }

  List<Widget> _actionButtons(
    AnalyticsApiService analyticsApiService,
    NavigationService navigationService,
    WidgetRef ref,
  ) {
    final isReceiver = analytic.canAccept ?? tabBarType == 'received';
    final openStatus = tabBarType != 'history' &&
        analytic.status != 'rejected' &&
        analytic.status != 'completed';
    final showComplete = openStatus &&
        analytic.status == 'accepted' &&
        analytic.type != 'One v One Meeting';
    final showAccept = isReceiver &&
        openStatus &&
        analytic.type != 'One v One Meeting' &&
        analytic.status != 'accepted';
    final showSchedule = isReceiver &&
        openStatus &&
        analytic.type == 'One v One Meeting' &&
        analytic.status != 'meeting_scheduled';
    final showMeetingComplete =
        openStatus && analytic.status == 'meeting_scheduled';
    final showReject = isReceiver && openStatus;
    final showCancel = (tabBarType == 'sent' || analytic.user_id == id) &&
        analytic.status != 'completed' &&
        analytic.status != 'rejected';

    Future<void> updateStatus(String action) async {
      await analyticsApiService.updateAnalyticStatus(
        analyticId: analytic.id ?? '',
        action: action,
      );
      ref.invalidate(fetchAnalyticsProvider);
      navigationService.pop();
    }

    return [
      if (showAccept)
        _outlineAction(
          label: 'Accept',
          color: const Color(0xFF16A34A),
          onPressed: () => updateStatus('accepted'),
        ),
      if (showSchedule)
        _outlineAction(
          label: 'Schedule',
          color: const Color(0xFF2B74E1),
          onPressed: () => updateStatus('meeting_scheduled'),
        ),
      if (showComplete || showMeetingComplete)
        _outlineAction(
          label: showMeetingComplete ? 'Complete' : 'Mark as Completed',
          color: const Color(0xFF16A34A),
          onPressed: () => updateStatus('completed'),
        ),
      if (showReject)
        _textAction(
          label: 'Reject',
          onPressed: () => updateStatus('rejected'),
        ),
      if (showCancel)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _textAction(
          label: 'Cancel Request',
          onPressed: () async {
            await analyticsApiService.deleteAnalytic(
              analyticId: analytic.id ?? '',
            );
            ref.invalidate(fetchAnalyticsProvider);
            navigationService.pop();
          },
        ),
        ),
    ];
  }

  Widget _outlineAction({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        height: 46,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color, width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _textAction({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFFEC4444),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _StatusStyle {
  final String label;
  final Color background;
  final Color foreground;

  const _StatusStyle(this.label, this.background, this.foreground);
}
