import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../domain/entities/check_out_summary.dart';
import '../providers/checkout_providers.dart';

/// Shown after the user completes a check-out. Summarizes the day's
/// attendance and timesheet status, with actions to complete the timesheet
/// or head back home.
class CheckOutScreen extends ConsumerWidget {
  const CheckOutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(checkOutSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Check out',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'PlayfairDisplay',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
            vertical: AppSpacing.pageVertical,
          ),
          child: Column(
            children: [
              const _StatusIcon(),
              const SizedBox(height: AppSpacing.xxl),
              const Text(
                'Day Complete!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                "You've met the minimum required hours.\nYour attendance is marked final.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _GeofencePill(isWithinGeofence: summary.isWithinGeofence),
              const SizedBox(height: AppSpacing.xxl),
              _SummaryCard(summary: summary),
              const SizedBox(height: AppSpacing.lg),
              _TimesheetBanner(summary: summary),
              const SizedBox(height: AppSpacing.xxxl),
              _PrimaryActionButton(
                label: 'Complete Timesheet',
                icon: Icons.assignment_turned_in_outlined,
                onPressed: () {
                  // TODO: navigate to the timesheet completion flow,
                  // e.g. context.push(AppRoutes.timesheet);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              _SecondaryActionButton(
                label: 'Back to Home',
                onPressed: () {
                  // Reset check-in status when going back to home
                  ref.read(dashboardStateProvider.notifier).setCheckedIn(false);
                  context.go(AppRoutes.dashboard);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Soft green circular icon at the top of the screen.
class _StatusIcon extends StatelessWidget {
  const _StatusIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      decoration: const BoxDecoration(
        color: AppColors.secondary100,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.event_available_rounded,
        color: AppColors.secondary700,
        size: 48,
      ),
    );
  }
}

/// "Within geofence" pill shown under the headline copy.
class _GeofencePill extends StatelessWidget {
  const _GeofencePill({required this.isWithinGeofence});

  final bool isWithinGeofence;

  @override
  Widget build(BuildContext context) {
    final color = isWithinGeofence ? AppColors.secondary700 : AppColors.error;
    final bg = isWithinGeofence ? AppColors.secondary50 : AppColors.error.withOpacity(0.08);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, color: color, size: 16),
          const SizedBox(width: AppSpacing.xs),
          Text(
            isWithinGeofence ? 'Within geofence' : 'Outside geofence',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card listing check-in/out times, total hours, and location.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final CheckOutSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _InfoRow(label: 'Check in', value: _formatTime(summary.checkInTime)),
          const _RowDivider(),
          _InfoRow(label: 'check out', value: _formatTime(summary.checkOutTime)),
          const _RowDivider(),
          _InfoRow(
            label: 'Total hours',
            value: _formatDuration(summary.totalWorked),
            valueColor: AppColors.secondary700,
          ),
          const _RowDivider(),
          _InfoRow(label: 'Location', value: summary.location),
        ],
      ),
    );
  }

  static String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour : $minute';
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: AppColors.border);
  }
}

/// Callout banner nudging the user to finish logging timesheet hours.
class _TimesheetBanner extends StatelessWidget {
  const _TimesheetBanner({required this.summary});

  final CheckOutSummary summary;

  @override
  Widget build(BuildContext context) {
    final remaining = summary.timesheetRemainingHours;
    final remainingLabel = remaining % 1 == 0
        ? remaining.toStringAsFixed(0)
        : remaining.toStringAsFixed(1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.primary100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: AppColors.primary700,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(
              Icons.priority_high_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timesheet — ${summary.timesheetLoggedHours.toStringAsFixed(1)} / '
                      '${summary.timesheetRequiredHours.toStringAsFixed(0)} hrs Logged',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Add $remainingLabel hrs and submit your timesheet before '
                      'end of day to complete your record.',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary700,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary700,
          side: const BorderSide(color: AppColors.primary200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}