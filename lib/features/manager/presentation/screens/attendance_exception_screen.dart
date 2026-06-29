import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/approval_bottom_nav_bar.dart';
import '../widgets/approval_filter_tabs.dart';
import '../widgets/approval_request_card.dart';
import '../widgets/approval_screen_header.dart';
import '../widgets/sla_warning_banner.dart';

// ---------------------------------------------------------------------------
// Dummy data
// ---------------------------------------------------------------------------

class _AttendanceExceptionRequest {
  final String employeeName;
  final String empCode;
  final String date;
  final String reason;
  final String remarks;
  final String? slaLabel;
  final ApprovalCardStatus status;

  const _AttendanceExceptionRequest({
    required this.employeeName,
    required this.empCode,
    required this.date,
    required this.reason,
    required this.remarks,
    this.slaLabel,
    this.status = ApprovalCardStatus.pending,
  });
}

final _dummyRequests = [
  const _AttendanceExceptionRequest(
    employeeName: 'Aditya Kumar',
    empCode: 'EMP-0042',
    date: 'Wed, 4 Jun 2025',
    reason: 'Outside geofence — WFH',
    remarks: '"Working from home — plumber visit"',
    status: ApprovalCardStatus.approved,
  ),
  const _AttendanceExceptionRequest(
    employeeName: 'Aditya Kumar',
    empCode: 'EMP-0042',
    date: 'Wed, 4 Jun 2025',
    reason: 'Outside geofence — WFH',
    remarks: '"Working from home — plumber visit"',
    slaLabel: '1h 45m',
    status: ApprovalCardStatus.pending,
  ),
  const _AttendanceExceptionRequest(
    employeeName: 'Aditya Kumar',
    empCode: 'EMP-0042',
    date: 'Wed, 4 Jun 2025',
    reason: 'Outside geofence — WFH',
    remarks: '"Working from home — plumber visit"',
    slaLabel: '1h 45m',
    status: ApprovalCardStatus.pending,
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class AttendanceExceptionScreen extends ConsumerStatefulWidget {
  const AttendanceExceptionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AttendanceExceptionScreen> createState() =>
      _AttendanceExceptionScreenState();
}

class _AttendanceExceptionScreenState
    extends ConsumerState<AttendanceExceptionScreen> {
  ApprovalFilter _filter = ApprovalFilter.all;

  List<_AttendanceExceptionRequest> get _filtered {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const ApprovalScreenHeader(title: 'Attendance exception'),
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
                      line1Icon: Icons.location_on_outlined,
                      line2Icon: Icons.chat_bubble_outline_rounded,
                      onApprove: () {/* TODO */},
                      onReject: () {/* TODO */},
                      onDetail: () {/* TODO */},
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
