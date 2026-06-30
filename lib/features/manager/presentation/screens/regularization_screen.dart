import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/approval_bottom_nav_bar.dart';
import '../widgets/approval_filter_tabs.dart';
import '../widgets/approval_request_card.dart';
import '../widgets/approval_screen_header.dart';
import '../widgets/regularize_detail_dialog.dart';
import '../widgets/sla_warning_banner.dart';

// ---------------------------------------------------------------------------
// Dummy data
// ---------------------------------------------------------------------------

class _RegularizationRequest {
  final String employeeName;
  final String empCode;
  final String date;
  final String reason;
  final String remarks;
  final String? slaLabel;
  final ApprovalCardStatus status;

  // Fields shown inside the "Regularize Detail" pop-up.
  final String actualCheckInTime;
  final String detailRemarks;

  const _RegularizationRequest({
    required this.employeeName,
    required this.empCode,
    required this.date,
    required this.reason,
    required this.remarks,
    this.slaLabel,
    this.status = ApprovalCardStatus.pending,
    this.actualCheckInTime = '10:08:00 AM',
    this.detailRemarks =
    'Had to rush to client site for urgent requirement discussion '
        'before EOD. Left office premises at 6:20 PM.',
  });
}

final _dummyRequests = [
  const _RegularizationRequest(
    employeeName: 'Aditya Kumar',
    empCode: 'EMP-0042',
    date: 'Wed, 4 Jun 2025',
    reason: 'Missed check-in',
    remarks: 'Missed the reminder notification .....',
    slaLabel: '1h 45m',
  ),
  const _RegularizationRequest(
    employeeName: 'Aditya Kumar',
    empCode: 'EMP-0042',
    date: 'Wed, 4 Jun 2025',
    reason: 'Missed check-in',
    remarks: 'Missed the reminder notification .....',
    slaLabel: '1h 45m',
  ),
  const _RegularizationRequest(
    employeeName: 'Aditya Kumar',
    empCode: 'EMP-0042',
    date: 'Wed, 4 Jun 2025',
    reason: 'Missed check-in',
    remarks: 'Missed the reminder notification .....',
    slaLabel: '1h 45m',
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class RegularizationScreen extends ConsumerStatefulWidget {
  const RegularizationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegularizationScreen> createState() =>
      _RegularizationScreenState();
}

class _RegularizationScreenState extends ConsumerState<RegularizationScreen> {
  ApprovalFilter _filter = ApprovalFilter.all;

  List<_RegularizationRequest> get _filtered {
    switch (_filter) {
      case ApprovalFilter.all:
        return _dummyRequests;
      case ApprovalFilter.pending:
        return _dummyRequests
            .where((r) => r.status == ApprovalCardStatus.pending)
            .toList();
      case ApprovalFilter.approved:
        return _dummyRequests
            .where((r) => r.status == ApprovalCardStatus.approved)
            .toList();
      case ApprovalFilter.rejected:
        return _dummyRequests
            .where((r) => r.status == ApprovalCardStatus.rejected)
            .toList();
    }
  }

  void _openDetail(_RegularizationRequest r) {
    showRegularizeDetailDialog(
      context: context,
      detail: RegularizeDetail(
        requestType: r.reason,
        actualCheckInTime: r.actualCheckInTime,
        remarks: r.detailRemarks,
      ),
      onApprove: () {
        // TODO: hook up approve action
      },
      onReject: () {
        // TODO: hook up reject action
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const ApprovalScreenHeader(title: 'Regularization'),
            ApprovalFilterTabs(
              activeFilter: _filter,
              onFilterChanged: (f) => setState(() => _filter = f),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  const SlaWarningBanner(),
                  const SizedBox(height: 16),
                  ..._filtered.map(
                        (r) => ApprovalRequestCard(
                      employeeName: r.employeeName,
                      empCode: r.empCode,
                      date: r.date,
                      metaLine1: r.reason,
                      metaLine2: r.remarks,
                      slaLabel: r.slaLabel,
                      status: r.status,
                      line1Icon: Icons.info_outline_rounded,
                      line2Icon: Icons.chat_bubble_outline_rounded,
                      onApprove: () {/* TODO */},
                      onReject: () {/* TODO */},
                      onDetail: () => _openDetail(r),
                    ),
                  ),
                ],
              ),
            ),
            const ApprovalBottomNavBar(),
          ],
        ),
      ),
    );
  }
}