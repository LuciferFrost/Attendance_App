import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/dashboard_providers.dart';

import 'package:demo4/features/manager/presentation/providers/manager_overview_provider.dart';

enum _CheckInTimeResult { withinWindow, tooEarly, outsideWindow }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    ref.read(dashboardStateProvider.notifier).initializeUserData();
  }

  Future<void> _handleCheckIn() async {
    final state = ref.read(dashboardStateProvider);

    if (!state.isCheckedIn) {
      final now = TimeOfDay.now();
      final checkResult = _classifyCheckInTime(now, state);

      if (checkResult == _CheckInTimeResult.tooEarly) {
        // Navigate to the early check-in screen and wait for the user's choice.
        final result = await context.push<Map<String, dynamic>>(
          AppRoutes.earlyCheckIn,
          extra: state.shiftStartTime,
        );

        // User cancelled or closed the screen without proceeding.
        if (result == null || result['proceed'] != true) return;

        // Optional: forward reason/remarks to your check-in provider here.
        // ref.read(dashboardStateProvider.notifier)
        //     .setEarlyCheckInReason(result['reason'], result['remarks']);
      } else if (checkResult == _CheckInTimeResult.outsideWindow) {
        _showNotAllowedDialog(now, state);
        return;
      }
      // _CheckInTimeResult.withinWindow → fall through to normal check-in
    }

    context.push(AppRoutes.checkIn, extra: state.isCheckedIn);
  }

  _CheckInTimeResult _classifyCheckInTime(TimeOfDay now, DashboardState state) {
    final start = _parseTimeOfDay(state.shiftStartTime);
    final end = _parseTimeOfDay(state.shiftEndTime);
    if (start == null || end == null) return _CheckInTimeResult.withinWindow; // fail open

    final nowMinutes   = now.hour * 60 + now.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes   = end.hour * 60 + end.minute;
    final windowStart  = startMinutes - 30; // 30-min grace before shift

    final bool isNormalShift = endMinutes > startMinutes;

    if (isNormalShift) {
      // e.g. 9 AM – 6 PM
      if (nowMinutes < windowStart) return _CheckInTimeResult.tooEarly;
      if (nowMinutes > endMinutes)  return _CheckInTimeResult.outsideWindow;
      return _CheckInTimeResult.withinWindow;
    } else {
      // Overnight shift, e.g. 10 PM – 6 AM
      final bool beforeStart = nowMinutes < windowStart && nowMinutes > endMinutes;
      if (beforeStart) return _CheckInTimeResult.tooEarly;
      final bool withinWindow =
          nowMinutes >= windowStart || nowMinutes <= endMinutes;
      return withinWindow
          ? _CheckInTimeResult.withinWindow
          : _CheckInTimeResult.outsideWindow;
    }
  }

  TimeOfDay? _parseTimeOfDay(String timeStr) {
    // Expects format like "10:00 AM" or "06:30 PM"
    try {
      final parts = timeStr.trim().split(' ');
      final hm = parts[0].split(':');
      int hour = int.parse(hm[0]);
      final minute = int.parse(hm[1]);
      final period = parts[1].toUpperCase();
      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  void _showNotAllowedDialog(TimeOfDay now, DashboardState state) {
    final nowFormatted = _formatTimeOfDay(now);

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon circle
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_off_outlined,
                  color: Color(0xFFEF4444),
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Check-In Not Allowed',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'PlayfairDisplay',
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'You are trying to check in outside\nyour assigned shift window',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // Error detail box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0x33FFDAD6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFDAD6)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFEF4444),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF93000A),
                            height: 1.5,
                            fontFamily: 'DMSans',
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Check-in blocked. ',
                              style: TextStyle(fontWeight: FontWeight.w600,
                                  fontFamily: 'DMSans'),
                            ),
                            TextSpan(
                              text:
                              'Your ${state.shiftType} check-in window is '
                                  '${state.shiftStartTime}–${state.shiftEndTime}. '
                                  'It is currently $nowFormatted.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Back to Home button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.home_rounded, size: 20),
                  label: const Text('Back to Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B5BDB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        setState(() {
          _selectedNavIndex = index;
        });
        break;
      case 1:
        setState(() {
          _selectedNavIndex = index;
        });
        context.push(AppRoutes.attendance).then((_) => setState(() => _selectedNavIndex = 0));
        break;
      case 2:
        setState(() {
          _selectedNavIndex = index;
        });
        context.push(AppRoutes.meetings).then((_) => setState(() => _selectedNavIndex = 0));
        break;
      case 3:
        final isManager = ref.read(dashboardStateProvider).isManager;
        if (isManager) {
          setState(() {
            _selectedNavIndex = index;
          });
          context.push(AppRoutes.approvals).then((_) => setState(() => _selectedNavIndex = 0));
        }
        // If not manager, do nothing
        break;
      case 4:
        setState(() {
          _selectedNavIndex = index;
        });
        context.push(AppRoutes.profile).then((_) => setState(() => _selectedNavIndex = 0));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardStateProvider);
    final managerOverview = ref.watch(managerOverviewProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // DARK SECTION (Top Half)
              Container(
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    center: Alignment(0.8, -0.6),
                    radius: 1.2,
                    stops: [0.0, 0.4],
                    colors: [
                      Color(0xFF1D2B73),
                      Color(0xFF11141E),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    // Header
                    _buildHeader(),

                    // Main Content (Dark Background)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: AppSpacing.lg),
                          // Greeting
                          _buildGreeting(dashboardState),
                          SizedBox(height: AppSpacing.xl),
                          // Info Grid
                          _buildInfoGrid(dashboardState),
                          SizedBox(height: AppSpacing.xl),
                          // Action Grid
                          _buildActionGrid(dashboardState),
                          SizedBox(height: AppSpacing.xxxl),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // WHITE SECTION (Bottom Half)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: Column(
                  children: [
                    // Shift Summary
                    _buildShiftSummary(dashboardState),
                    const SizedBox(height: 20),
                    if (dashboardState.isManager) ...[
                      _buildManagerOverview(managerOverview),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Craft',
                  style: AppTypography.heading2?.copyWith(
                    fontFamily: 'PlayfairDisplay',
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                TextSpan(
                  text: 'edge',
                  style: AppTypography.heading2?.copyWith(
                    fontFamily: 'PlayfairDisplay',
                    color: AppColors.primary700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildIconButton(
                icon: Icons.notifications_none_rounded,
                onTap: () {
                  context.push(AppRoutes.notifications);
                },
              ),
              const SizedBox(width: 12),
              _buildIconButton(
                icon: Icons.person_outline_rounded,
                onTap: () {
                  context.push(AppRoutes.profile);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2D333F),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: const Color(0xFFB0B8C1),
        ),
      ),
    );
  }

  Widget _buildGreeting(DashboardState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 220,
              child: Text(
                'Good Morning, ${state.displayName}',
                style: AppTypography.heading2?.copyWith(
                  fontFamily: 'PlayfairDisplay',
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoGrid(DashboardState state) {
    return Row(
      children: [
        _buildInfoBox2(state.employeeCode),
        const SizedBox(width: 8),
        _buildInfoBox2(state.shiftType),
        const SizedBox(width: 8),
        _buildInfoBox2(state.currentDate),
      ],
    );
  }

  Widget _buildInfoBox2(String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2D333F),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 11,
                  fontFamily: "LiberationSans"
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGrid(DashboardState state) {
    final actions = [
      {
        'icon': state.isCheckedIn ? 'assets/images/home_Checkout.png' : 'assets/images/home_Checkin.png',
        'label': state.isCheckedIn ? 'Check Out' : 'Check In',
        'count': state.isCheckedIn ? 'Tap to end day' : 'Tap to start day',
        'tint': state.isCheckedIn ? const Color(0x1AFA5252) : const Color(0x1A10B981),
      },
      {
        'icon': 'assets/images/home_Attendance.png',
        'label': 'Attendance',
        'count': '${state.attendedDays} days',
        'tint': const Color(0x1A4353FF),
      },
      {
        'icon': 'assets/images/home_timesheet.png',
        'label': 'Timesheet',
        'count': '3 pending',
        'tint': const Color(0x1AF97316),
      },
      {
        'icon': 'assets/images/home_leave.png',
        'label': 'Apply Leave',
        'count': '${state.leavesLeft}/${state.totalLeaves}',
        'tint': const Color(0x1AA855F7),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            switch (index) {
              case 0:
                _handleCheckIn();
                break;
              case 1:
                context.push(AppRoutes.attendance);
                break;
              case 2:
                context.push(AppRoutes.timesheet);
                break;
              case 3:
                context.push(AppRoutes.leave);
                break;
            }
          },
          child: _buildActionCard(
            iconPath: actions[index]['icon'] as String,
            label: actions[index]['label'] as String,
            count: actions[index]['count'] as String,
            tint: actions[index]['tint'] as Color,
          ),
        );
      },
    );
  }

  Widget _buildActionCard({
    required String iconPath,
    required String label,
    required String count,
    required Color tint,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2D333F),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              iconPath,
              width: 24,
              height: 24,
              color: tint.withOpacity(1.0),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTypography.heading2?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: AppTypography.bodySmall?.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleCheckIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A1D27),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/home_Checkin_button.png',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 5),
            Text(
              'Check In',
              style: AppTypography.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
                fontFamily: 'DMSans',
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckOutButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF3E6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            'You are currently checked in. Don\'t forget to check out when your shift is over.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium?.copyWith(
              color: const Color(0xFF92400E),
              fontWeight: FontWeight.w500,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleCheckIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1D27),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/home_Checkin_button.png',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Check Out',
                    style: AppTypography.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                      fontFamily: 'DMSans',
                      fontSize: 16,
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

  Widget _buildShiftSummary(DashboardState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildChip(state.shiftPeriod, AppColors.homeShift, Colors.white),
              const SizedBox(width: 12),
              if (state.isCheckedIn)
                _buildChip(
                  state.workLocation,
                  const Color(0x4D5FC69A),
                  const Color(0xFF10B981),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Progress",
                style: AppTypography.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                  letterSpacing: 0.3,
                ),
              ),
              Row(
                children: [
                  _buildTimeBox(state.shiftStartTime, state.shiftEndTime),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final progressWidth = constraints.maxWidth * (state.progressPercentage / 100);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: state.progressPercentage / 100,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF3B5BDB),
                      ),
                    ),
                  ),
                  Positioned(
                    left: progressWidth - 8,
                    top: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF3B5BDB),
                          width: 3,
                        ),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.hoursWorked.toStringAsFixed(1)}/8 hours',
                style: AppTypography.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Text(
                '${state.timeRemaining} left',
                style: AppTypography.bodySmall?.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          state.isCheckedIn ? _buildCheckOutButton() : _buildCheckInButton(),
        ],
      ),
    );
  }

  Widget _buildManagerOverview(ManagerOverviewState overview) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MANAGER OVERVIEW',
                style: AppTypography.caption?.copyWith(
                  color: const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  fontSize: 11,
                ),
              ),
              GestureDetector(
                onTap: () {

                  context.push(AppRoutes.teamAttendance);
                },
                child: Text(
                  'View details',
                  style: AppTypography.caption?.copyWith(
                    color: const Color(0xFF818CF8),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Date + team count
          Text(
            '${overview.date} • ${overview.teamMemberCount} team members',
            style: AppTypography.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),

          // Stat tiles
          Row(
            children: [
              _buildManagerStatTile(
                value: overview.stats.present,
                label: 'PRESENT',
                color: const Color(0xFF10B981),
              ),
              const SizedBox(width: 8),
              _buildManagerStatTile(
                value: overview.stats.absent,
                label: 'ABSENT',
                color: const Color(0xFFEF4444),
              ),
              const SizedBox(width: 8),
              _buildManagerStatTile(
                value: overview.stats.halfDay,
                label: 'HALF DAY',
                color: const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 8),
              _buildManagerStatTile(
                value: overview.stats.pending,
                label: 'PENDING',
                color: const Color(0xFF818CF8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManagerStatTile({
    required int value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF252B3B),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                fontFamily: 'DMSans',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.caption?.copyWith(
                color: const Color(0xFF9CA3AF),
                fontSize: 9,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color backgroundColor, Color txtColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.caption?.copyWith(
          color: txtColor,
          fontSize: 11,
          fontWeight: FontWeight.w400,
          fontFamily: "LiberationSans",
        ),
      ),
    );
  }

  Widget _buildTimeBox(String time1, String time2) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time1,
            style: AppTypography.bodySmall?.copyWith(
              color: const Color(0xFF4353FF),
              fontWeight: FontWeight.w500,
              fontFamily: 'DMMono',
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '—',
              style: TextStyle(
                color: Color(0xFF4353FF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'DMMono',
              ),
            ),
          ),
          Text(
            time2,
            style: AppTypography.bodySmall?.copyWith(
              color: const Color(0xFF4353FF),
              fontWeight: FontWeight.w500,
              fontFamily: 'DMMono',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final navItems = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': 'assets/images/home_NavAttend.png', 'label': 'Attend.'},
      {'icon': 'assets/images/home_NavMeetings.png', 'label': 'Meetings'},
      {'icon': 'assets/images/home_NavApproval.png', 'label': 'Approvals'},
      {'icon': 'assets/images/home_NavProfile.png', 'label': 'Profile'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          navItems.length,
              (index) => _buildNavItem(
            icon: navItems[index]['icon'],
            label: navItems[index]['label'] as String,
            index: index,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required dynamic icon,
    required String label,
    required int index,
  }) {
    final isActive = _selectedNavIndex == index;

    return GestureDetector(
      onTap: () => _handleNavigation(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon is IconData)
              Icon(
                icon,
                size: 20,
                color: isActive ? AppColors.primary700 : const Color(0xFF6B7280),
              )
            else if (icon is String)
              Image.asset(
                icon,
                width: 20,
                height: 20,
                color: isActive ? AppColors.primary700 : const Color(0xFF6B7280),
              ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.caption?.copyWith(
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.primary700 : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}