import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/leave_balance.dart';
import '../../domain/entities/leave_request.dart';
import '../providers/leave_providers.dart';

class LeaveDashboardScreen extends ConsumerStatefulWidget {
  const LeaveDashboardScreen({super.key});

  @override
  ConsumerState<LeaveDashboardScreen> createState() =>
      _LeaveDashboardScreenState();
}

class _LeaveDashboardScreenState extends ConsumerState<LeaveDashboardScreen> {
  /// null = show all; otherwise filter to this status
  LeaveStatus? _statusFilter;

  List<LeaveRequest> _applyFilter(List<LeaveRequest> all) {
    if (_statusFilter == null) return all;
    return all.where((r) => r.status == _statusFilter).toList();
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter by status',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF11141E),
                  ),
                ),
                const SizedBox(height: 16),
                _FilterOption(
                  label: 'All',
                  selected: _statusFilter == null,
                  onTap: () {
                    setState(() => _statusFilter = null);
                    Navigator.pop(ctx);
                  },
                ),
                _FilterOption(
                  label: 'Approved',
                  selected: _statusFilter == LeaveStatus.approved,
                  onTap: () {
                    setState(() => _statusFilter = LeaveStatus.approved);
                    Navigator.pop(ctx);
                  },
                ),
                _FilterOption(
                  label: 'Rejected',
                  selected: _statusFilter == LeaveStatus.rejected,
                  onTap: () {
                    setState(() => _statusFilter = LeaveStatus.rejected);
                    Navigator.pop(ctx);
                  },
                ),
                _FilterOption(
                  label: 'Pending',
                  selected: _statusFilter == LeaveStatus.pending,
                  onTap: () {
                    setState(() => _statusFilter = LeaveStatus.pending);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(leaveBalanceProvider);
    final allHistory = ref.watch(leaveHistoryProvider);
    final history = _applyFilter(allHistory);

    final monthFmt = DateFormat('d MMMM');

    return Scaffold(
      backgroundColor: Colors.white,
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
          'Leave',
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Balance card ─────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2035),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'YOUR LEAVE BALANCE',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9CA3AF),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_month_outlined,
                              color: Color(0xFF9CA3AF),
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${monthFmt.format(balance.periodStart)} – ${monthFmt.format(balance.periodEnd)}',
                          style: const TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _BalanceTile(
                              count: balance.casualLeave,
                              label: 'Casual leave',
                            ),
                            const SizedBox(width: 10),
                            _BalanceTile(
                              count: balance.shortLeave,
                              label: 'Short leave',
                            ),
                            const SizedBox(width: 10),
                            _BalanceTile(
                              count: balance.lateMark,
                              label: 'Late mark',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Recent History header ─────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent History',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF11141E),
                        ),
                      ),
                      GestureDetector(
                        onTap: _showFilterSheet,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(
                              Icons.filter_alt_outlined,
                              size: 22,
                              color: Color(0xFF6B7280),
                            ),
                            if (_statusFilter != null)
                              Positioned(
                                top: -3,
                                right: -3,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4F46E5),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── History list ──────────────────────────────────────────
                  if (history.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Center(
                        child: Text(
                          'No leave records for the selected filter.',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: history.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          thickness: 1,
                          indent: 20,
                          endIndent: 20,
                          color: Color(0xFFF3F4F6),
                        ),
                        itemBuilder: (ctx, i) => _LeaveHistoryTile(history[i]),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Apply Leave button pinned at the bottom ───────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.leaveApply),
              icon: const Icon(
                Icons.calendar_month_outlined,
                size: 20,
                color: Colors.white,
              ),
              label: const Text(
                'Apply Leave',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ────────────────────────────────────────────────────────────

class _BalanceTile extends StatelessWidget {
  final int count;
  final String label;

  const _BalanceTile({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF232B40),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: const TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 15,
                  fontWeight:
                  selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected
                      ? const Color(0xFF4F46E5)
                      : const Color(0xFF374151),
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_rounded,
                  size: 18, color: Color(0xFF4F46E5)),
          ],
        ),
      ),
    );
  }
}

class _LeaveHistoryTile extends StatelessWidget {
  final LeaveRequest leave;

  const _LeaveHistoryTile(this.leave);

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('d MMM');
    final dateStr = dateFmt.format(leave.leaveDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Icon badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _iconBg(leave.type),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                _icon(leave.type),
                size: 20,
                color: _iconColor(leave.type),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${leave.type.shortLabel} · $dateStr',
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF11141E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  leave.subtitle,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Status badge
          _StatusBadge(leave.status),
        ],
      ),
    );
  }

  Color _iconBg(LeaveType type) {
    switch (type) {
      case LeaveType.casual:
        return const Color(0xFFDCFCE7);
      case LeaveType.sick:
        return const Color(0xFFEDE9FE);
      case LeaveType.halfDay:
        return const Color(0xFFEDE9FE);
      case LeaveType.shortLeave:
        return const Color(0xFFFFF7ED);
      case LeaveType.earned:
        return const Color(0xFFDBEAFE);
    }
  }

  Color _iconColor(LeaveType type) {
    switch (type) {
      case LeaveType.casual:
        return const Color(0xFF16A34A);
      case LeaveType.sick:
        return const Color(0xFF7C3AED);
      case LeaveType.halfDay:
        return const Color(0xFF4F46E5);
      case LeaveType.shortLeave:
        return const Color(0xFFF97316);
      case LeaveType.earned:
        return const Color(0xFF2563EB);
    }
  }

  IconData _icon(LeaveType type) {
    switch (type) {
      case LeaveType.casual:
        return Icons.schedule_outlined;
      case LeaveType.sick:
        return Icons.schedule_outlined;
      case LeaveType.halfDay:
        return Icons.schedule_outlined;
      case LeaveType.shortLeave:
        return Icons.schedule_outlined;
      case LeaveType.earned:
        return Icons.schedule_outlined;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final LeaveStatus status;

  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status) {
      case LeaveStatus.approved:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF16A34A);
        break;
      case LeaveStatus.rejected:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        break;
      case LeaveStatus.pending:
        bg = const Color(0xFFFFF7ED);
        fg = const Color(0xFFF97316);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}