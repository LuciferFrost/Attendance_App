import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/approval_bottom_nav_bar.dart';
import '../widgets/approval_filter_tabs.dart';
import '../widgets/approval_request_card.dart';
import '../widgets/approval_screen_header.dart';
import '../widgets/sla_warning_banner.dart';
import '../widgets/exception_detail_dialog.dart';
import '../widgets/rejection_reason_dialog.dart';

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
  final String locationLabel;
  final String coordinatesLabel;

  const _AttendanceExceptionRequest({
    required this.employeeName,
    required this.empCode,
    required this.date,
    required this.reason,
    required this.remarks,
    this.slaLabel,
    this.status = ApprovalCardStatus.pending,
    this.locationLabel = 'CraftEdge Office, Sector 62, Noida',
    this.coordinatesLabel = '19.1234°N, 72.8567°E',
  });
  _AttendanceExceptionRequest copyWith({ApprovalCardStatus? status}) {
    return _AttendanceExceptionRequest(
      employeeName: employeeName,
      empCode: empCode,
      date: date,
      reason: reason,
      remarks: remarks,
      slaLabel: slaLabel,
      status: status ?? this.status,
      locationLabel: locationLabel,
      coordinatesLabel: coordinatesLabel,
    );
  }
}

final List<_AttendanceExceptionRequest> _initialRequests = [
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
  late List<_AttendanceExceptionRequest> _requests;

  @override
  void initState() {
    super.initState();
    _requests = List.from(_initialRequests);
  }

  void _updateStatus(int index, ApprovalCardStatus status) {
    setState(() {
      _requests[index] = _requests[index].copyWith(status: status);
    });
  }

  List<_AttendanceExceptionRequest> get _filtered {
    switch (_filter) {
      case ApprovalFilter.all:
        return _requests;
      case ApprovalFilter.pending:
        return _requests
            .where((r) => r.status == ApprovalCardStatus.pending)
            .toList();
      case ApprovalFilter.approved:
        return _requests
            .where((r) => r.status == ApprovalCardStatus.approved)
            .toList();
      case ApprovalFilter.rejected:
        return _requests
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
                  ..._requests.asMap().entries.where((entry) {
                    if (_filter == ApprovalFilter.all) return true;
                    if (_filter == ApprovalFilter.pending) {
                      return entry.value.status == ApprovalCardStatus.pending;
                    }
                    if (_filter == ApprovalFilter.approved) {
                      return entry.value.status == ApprovalCardStatus.approved;
                    }
                    if (_filter == ApprovalFilter.rejected) {
                      return entry.value.status == ApprovalCardStatus.rejected;
                    }
                    return false;
                  }).map(
                        (entry) {
                      final index = entry.key;
                      final r = entry.value;
                      return ApprovalRequestCard(
                        employeeName: r.employeeName,
                        empCode: r.empCode,
                        date: r.date,
                        metaLine1: r.reason,
                        metaLine2: r.remarks,
                        slaLabel: r.slaLabel,
                        status: r.status,
                        line1Icon: Icons.location_on_outlined,
                        line2Icon: Icons.chat_bubble_outline_rounded,
                        onApprove: () {
                          // Open detail dialog first as requested
                          _showDetail(index, r);
                        },
                        onReject: () {
                          // Open detail dialog first as requested
                          _showDetail(index, r);
                        },
                        onDetail: () => _showDetail(index, r),
                      );
                    },
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

  void _showDetail(int index, _AttendanceExceptionRequest r) {
    final bool isPending = r.status == ApprovalCardStatus.pending;

    ExceptionDetailDialog.show(
      context,
      exceptionReason: r.reason,
      remarks: r.remarks,
      locationLabel: r.locationLabel,
      coordinatesLabel: r.coordinatesLabel,
      // Already approved/rejected: read-only view, no action buttons.
      // ExceptionDetailDialog should render a single "Back to approval"
      // button (which just closes the dialog) whenever onApprove and
      // onReject are both null.
      onApprove: isPending
          ? () {
        _updateStatus(index, ApprovalCardStatus.approved);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exception Approved')),
        );
      }
          : null,
      onReject: isPending
          ? () {
        RejectionReasonDialog.show(context).then((result) {
          if (result == true) {
            _updateStatus(index, ApprovalCardStatus.rejected);
          }
        });
      }
          : null,
    );
  }
}