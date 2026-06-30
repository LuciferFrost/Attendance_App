import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routing/app_routes.dart';
import '../widgets/approval_bottom_nav_bar.dart';
import 'timesheet_approvals_screen.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class _ApprovalQueue {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String? route;

  const _ApprovalQueue({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.route,
  });
}

const _queues = [
  _ApprovalQueue(
    title: 'Attendance Exception',
    subtitle: '3 Pending',
    icon: Icons.location_on_outlined,
    iconColor: Color(0xFFD97706),
    iconBg: Color(0xFFFEF3C7),
    route: AppRoutes.attendanceException,
  ),
  _ApprovalQueue(
    title: 'Regularization',
    subtitle: '2 Pending',
    icon: Icons.edit_outlined,
    iconColor: Color(0xFF4338CA),
    iconBg: Color(0xFFEEF2FF),
    route: AppRoutes.regularization,
  ),
  _ApprovalQueue(
    title: 'Leave approvals',
    subtitle: '4 Pending',
    icon: Icons.calendar_today_outlined,
    iconColor: Color(0xFF059669),
    iconBg: Color(0xFFD1FAE5),
    route: AppRoutes.leaveApprovals,
  ),
  _ApprovalQueue(
    title: 'Timesheets',
    subtitle: '5 Pending',
    icon: Icons.assignment_outlined,
    iconColor: Color(0xFF7C3AED),
    iconBg: Color(0xFFF3E8FF),
    route: 'timesheets',
  ),
  _ApprovalQueue(
    title: 'My Request',
    subtitle: 'Track status',
    icon: Icons.person_outline_rounded,
    iconColor: Color(0xFF4338CA),
    iconBg: Color(0xFFEEF2FF),
    route: AppRoutes.myRequests,
  ),
];

const int _totalPending = 14;

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class ApprovalsScreen extends ConsumerWidget {
  const ApprovalsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  children: [
                    _buildBanner(),
                    const SizedBox(height: 24),
                    ..._queues.map((q) => _buildQueueTile(context, q)),
                  ],
                ),
              ),
            ),
            const ApprovalBottomNavBar(activeIndex: 3),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
          color: const Color(0xFF11141E)
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          ),
          Center(
            child: Text(
              'Approvals',
              style: AppTypography.heading2?.copyWith(
                color: Colors.white,
                fontFamily: 'PlayfairDisplay',
                fontSize: 24,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Banner ────────────────────────────────────────────────────────────────

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFF3B5BDB),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  fontFamily: 'DMSans',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_totalPending requests need your decision',
                  style: AppTypography.bodyMedium?.copyWith(
                      color: const Color(0xFF3B5BDB),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      fontFamily: 'DMSans'
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap a queue to review. Rejections always require remarks.',
                  style: AppTypography.bodySmall?.copyWith(
                      color: const Color(0xFF464555),
                      height: 1.4,
                      fontFamily: 'DMSans',
                      fontWeight: FontWeight.w400,
                      fontSize: 14
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Queue tile ────────────────────────────────────────────────────────────

  Widget _buildQueueTile(BuildContext context, _ApprovalQueue q) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (q.route == 'timesheets') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TimesheetApprovalsScreen(),
                ),
              );
            } else if (q.route != null) {
              context.push(q.route!);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              /*boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],*/
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: q.iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(q.icon, color: q.iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q.title,
                        style: AppTypography.bodyMedium?.copyWith(
                            color: const Color(0xFF1E293B),
                            fontWeight: FontWeight.w700,
                            fontFamily: 'DMSans',
                            fontSize: 14

                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        q.subtitle,
                        style: AppTypography.caption?.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontSize: 11,
                          fontFamily: 'DMSans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFD1D5DB),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
