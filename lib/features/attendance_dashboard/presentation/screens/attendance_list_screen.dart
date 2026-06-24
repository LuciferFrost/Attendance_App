import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/attendance_record.dart';
import '../providers/attendance_history_providers.dart';

/// "Attendance" list screen — shows a date-filterable list of the
/// employee's attendance days, with quick access to the detail view and
/// to raising a correction ("Regularize") request for days that need one.
class AttendanceListScreen extends ConsumerStatefulWidget {
  const AttendanceListScreen({super.key});

  @override
  ConsumerState<AttendanceListScreen> createState() =>
      _AttendanceListScreenState();
}

class _AttendanceListScreenState extends ConsumerState<AttendanceListScreen> {
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  String _tagFilter = 'Tags';
  String _statusFilter = 'All Status';

  static const _tagOptions = ['Tags', 'Present', 'Late', 'Half Day', 'Absent'];
  static const _statusOptions = [
    'All Status',
    'Approved',
    'Pending Approval',
    'Rejected',
  ];

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B5BDB),
              onPrimary: Colors.white,
              onSurface: Color(0xFF11141E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  List<AttendanceRecord> _applyFilters(List<AttendanceRecord> records) {
    return records.where((record) {
      final inRange = !record.date.isBefore(
            DateTime(_dateRange.start.year, _dateRange.start.month, _dateRange.start.day),
          ) &&
          !record.date.isAfter(
            DateTime(_dateRange.end.year, _dateRange.end.month, _dateRange.end.day),
          );
      if (!inRange) return false;

      if (_tagFilter != 'Tags') {
        bool matchesTag;
        switch (_tagFilter) {
          case 'Present':
            matchesTag = record.status == AttendanceStatus.present;
            break;
          case 'Late':
            matchesTag = record.status == AttendanceStatus.late;
            break;
          case 'Half Day':
            matchesTag = record.status == AttendanceStatus.halfDay;
            break;
          case 'Absent':
            matchesTag = record.status == AttendanceStatus.absent;
            break;
          default:
            matchesTag = true;
        }
        if (!matchesTag) return false;
      }

      if (_statusFilter != 'All Status') {
        bool matchesStatus;
        switch (_statusFilter) {
          case 'Pending Approval':
            matchesStatus =
                record.regularizationState == RegularizationState.pendingApproval;
            break;
          case 'Approved':
            matchesStatus = record.regularizationState == RegularizationState.approved;
            break;
          case 'Rejected':
            matchesStatus = record.regularizationState == RegularizationState.rejected;
            break;
          default:
            matchesStatus = true;
        }
        if (!matchesStatus) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(attendanceHistoryProvider);
    final records = _applyFilters(allRecords);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF11141E),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.darkTextPrimary,
            size: 24,
          ),
        ),
        title: const Text(
          'Attendance',
          style: TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.w400,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              children: [
                Expanded(flex: 3, child: _buildDateRangeChip()),
                const SizedBox(width: 8),
                Expanded(flex: 2, child: _buildFilterDropdown(
                  value: _tagFilter,
                  options: _tagOptions,
                  onChanged: (v) => setState(() => _tagFilter = v),
                )),
                const SizedBox(width: 3),
                Expanded(flex: 2, child: _buildFilterDropdown(
                  value: _statusFilter,
                  options: _statusOptions,
                  onChanged: (v) => setState(() => _statusFilter = v),
                )),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
          Expanded(
            child: records.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    itemCount: records.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _buildAttendanceCard(records[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_busy_rounded, size: 40, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 12),
            const Text(
              'No attendance records for the selected filters',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeChip() {
    final formatter = DateFormat('dd/MM/yyyy');
    return GestureDetector(
      onTap: _pickDateRange,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE3E7EF)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF6B7280)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${formatter.format(_dateRange.start)} - ${formatter.format(_dateRange.end)}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3FC),
        borderRadius: BorderRadius.circular(999),

        border: Border.all(color: const Color(0xFFE3E7EF)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF6B7280)),
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          items: options
              .map((o) => DropdownMenuItem(
                    value: o,
                    child: Text(o, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(AttendanceRecord record) {
    final hasPunches = record.checkInTime != null && record.checkOutTime != null;
    final isPendingApproval =
        record.regularizationState == RegularizationState.pendingApproval;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  DateFormat('EEE, dd MMM').format(record.date),
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF11141E),
                  ),
                ),
              ),
              _buildActionLink(record, hasPunches),
            ],
          ),
          const SizedBox(height: 6),
          _buildStatusBadge(record, isPendingApproval),
          const SizedBox(height: 14),
          if (record.statusNote != null) ...[
            _buildStatusNoteBanner(record.statusNote!),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F9), // greyish tint
                borderRadius: BorderRadius.circular(12),
                // border: Border.all(color: const Color(0xFFE3E7EF)), // optional
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTimeColumn(
                      'CHECK IN',
                      record.checkInTime != null
                          ? DateFormat('hh:mm a').format(record.checkInTime!)
                          : '-',
                    ),
                  ),
                  Expanded(
                    child: _buildTimeColumn(
                      'CHECK OUT',
                      record.checkOutTime != null
                          ? DateFormat('hh:mm a').format(record.checkOutTime!)
                          : '-',
                    ),
                  ),
                  Expanded(
                    child: _buildTimeColumn(
                      'TOTAL',
                      record.totalHoursLabel ?? '-',
                      valueColor: record.status == AttendanceStatus.late
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF11141E),
                      alignEnd: true,
                    ),
                  ),
                ],
              ),
            )
          ],
        ],
      ),
    );
  }

  Widget _buildActionLink(AttendanceRecord record, bool hasPunches) {
    final isPendingApproval =
        record.regularizationState == RegularizationState.pendingApproval;

    if (isPendingApproval) {
      return const Text(
        'Regularize →',
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFFB0B5BC),
        ),
      );
    }

    final label = hasPunches ? 'View Detail' : 'Regularize';

    return GestureDetector(
      onTap: () {
        if (hasPunches) {
          context.push(AppRoutes.attendanceDetail, extra: record);
        } else {
          context.push(
            AppRoutes.attendanceCorrection,
            extra: {'record': record, 'openedFromList': true},
          );
        }
      },
      child: Text(
        '$label →',
        style: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF3B5BDB),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AttendanceRecord record, bool isPendingApproval) {
    final colors = _statusColors(record.status);
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Text(
            record.status.label,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colors.foreground,
              letterSpacing: 0.3,
            ),
          ),
        ),
        if (isPendingApproval)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'PENDING APPROVAL',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFB45309),
                letterSpacing: 0.3,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusNoteBanner(String note) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        note,
        style: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFFB91C1C),
        ),
      ),
    );
  }

  Widget _buildTimeColumn(
    String label,
    String value, {
    Color valueColor = const Color(0xFF11141E),
    bool alignEnd = false,
  }) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9CA3AF),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'DMMono',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  _StatusColors _statusColors(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return const _StatusColors(Color(0xFFDCFCE7), Color(0xFF15803D));
      case AttendanceStatus.late:
        return const _StatusColors(Color(0xFFFFEDD5), Color(0xFFC2410C));
      case AttendanceStatus.absent:
        return const _StatusColors(Color(0xFFFEE2E2), Color(0xFFB91C1C));
      case AttendanceStatus.halfDay:
        return const _StatusColors(Color(0xFFEDE9FE), Color(0xFF6D28D9));
    }
  }
}

/// Small value holder for a status badge's background/foreground colors.
class _StatusColors {
  final Color background;
  final Color foreground;

  const _StatusColors(this.background, this.foreground);
}
