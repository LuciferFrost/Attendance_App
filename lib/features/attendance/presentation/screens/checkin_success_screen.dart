import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:demo4/core/theme/app_colors.dart';
import 'package:demo4/core/theme/app_spacing.dart';
import 'package:demo4/core/theme/app_typography.dart';
import 'package:demo4/core/routing/app_routes.dart';
import 'package:demo4/features/dashboard/presentation/providers/dashboard_providers.dart';
import '../providers/checkin_providers.dart';


class CheckInSuccessScreen extends ConsumerWidget {
  final String attendanceStatus;
  final String geofenceStatus;
  final String checkInTime;
  final String workMode;
  final String location;
  final String shiftType;
  final bool approvalFound;
  final bool isWithinGeofence;
  final bool isCheckOut; // New parameter

  const CheckInSuccessScreen({
    super.key,
    required this.attendanceStatus,
    required this.geofenceStatus,
    required this.checkInTime,
    required this.workMode,
    required this.location,
    required this.shiftType,
    this.approvalFound = true,
    this.isWithinGeofence = false,
    this.isCheckOut = false, // Default to check-in
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: AppSpacing.lg),
              _buildSuccessIcon(),
              SizedBox(height: AppSpacing.lg),


              SizedBox(height: AppSpacing.lg),

              _buildTitle(),
              SizedBox(height: AppSpacing.md),
              _buildSubtitle(),
              SizedBox(height: AppSpacing.xl),
              _buildStatusChips(),
              SizedBox(height: AppSpacing.xl),
              // Approval notification - only shows if approvalFound && !isWithinGeofence

              _buildApprovalNotification(
                approvalFound: approvalFound,
                isWithinGeofence: isWithinGeofence,
              ),
              if(approvalFound && !isWithinGeofence) SizedBox(height: AppSpacing.xl),
              _buildLocationInfoBox(ref),
              SizedBox(height: AppSpacing.xl),
              _buildTimesheetNotifier(),
              SizedBox(height: AppSpacing.xl),
              _buildGoToHomeButton(context, ref),
              SizedBox(height: AppSpacing.md),
              _buildGoToTimesheetButton(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkSurface,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: const Center(
          child: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
      title: Text(
        isCheckOut ? 'Check out' : 'Check in',
        style: AppTypography.heading2.copyWith(
          color: Colors.white,
          fontFamily: 'LibSerif',
          fontWeight: FontWeight.w400,
          fontSize: 24,
        ),
      ),
      centerTitle: true,
      actions: [
        SizedBox(width: AppSpacing.lg),
      ],
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0x264CAF50),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Center(
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: const Color(0x4D4CAF50),
              width: 2,
            ),
          ),
          child: Image.asset(
            'assets/images/checkin_success_checkmark.png',
            width: 40,
            height: 40,
            color: const Color(0xFF4CAF50),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      isCheckOut ? 'Checked Out!' : 'Checked In!',
      style: AppTypography.heading1.copyWith(
          color: AppColors.neutral900,
          fontWeight: FontWeight.w700,
          fontFamily: 'PlayfairDisplay',
          fontSize: 24),
    );
  }

  Widget _buildSubtitle() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: isCheckOut 
                ? 'Your attendance has been marked as final for today.\n'
                : 'Your attendance has been marked as\n',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.neutral600,
              height: 1.5,
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w400,
            ),
          ),
          if (!isCheckOut)
            TextSpan(
              text: '$attendanceStatus-$workMode',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
                height: 1.5,
                fontFamily: 'DMSans',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChips() {
    return Wrap(
      spacing: AppSpacing.md,
      alignment: WrapAlignment.center,
      children: [
        _buildStatusChip(
          iconAsset: 'assets/images/checkin_success_checkmark2.png',
          label: geofenceStatus,
          color: AppColors.success,
        ),
        _buildStatusChip(
          label: attendanceStatus,
          color: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatusChip({
    required String label,
    required Color color,
    String? iconAsset,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconAsset != null) ...[
            Image.asset(
              iconAsset,
              width: 18,
              height: 18,
              color: color,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTypography.label.copyWith(
              color: color,
              fontWeight: FontWeight.w400,
              fontFamily: "LiberationSans",
            ),
          ),
        ],
      ),
    );
  }

  /// Approval notification widget - only shows if approvalFound && !isWithinGeofence
  Widget _buildApprovalNotification({
    required bool approvalFound,
    required bool isWithinGeofence,
  }) {
    // Only show if approval found AND user is outside geofence
    if (!approvalFound || isWithinGeofence) {
      return SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: const Color(0xFFA7F3D0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top chips

          const SizedBox(height: 12),

          // Main content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF10B981),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Approval Found',
                      style: AppTypography.heading3.copyWith(
                        color: const Color(0xFF065F46),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'DMSans',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pre-approved by: Priya Sharma (Manager)',
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF047857),
                        fontFamily: 'DMSans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Approved on: 1 Jun 2025 · Client Visit',
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF047857),
                        fontFamily: 'DMSans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper widget for small chips in approval notification


  Widget _buildLocationInfoBox(WidgetRef ref) {
    final currentDate = ref.watch(currentDateFormattedProvider);
    final currentTime = ref.watch(currentTimeFormattedProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            title: 'Employee',
            statusLabel: 'Rahul Kumar . EMP-1042',
            textColor: const Color(0xFF1F2937),
            showDivider: true,
          ),
          _buildInfoRow(
            title: 'Date',
            statusLabel: currentDate,
            textColor: const Color(0xFF1F2937),
            showDivider: true,
          ),
          _buildInfoRow(
            title: isCheckOut ? 'Check-Out Time' : 'Check-In Time',
            statusLabel: currentTime,
            textColor: const Color(0xFF10B981),
            showDivider: true,
          ),
          _buildInfoRow(
            title: 'Work Type',
            statusLabel: 'Work from office',
            textColor: const Color(0xFF1F2937),
            showDivider: true,
          ),
          _buildInfoRow(
            title: 'Geofence',
            statusLabel: 'Passed',
            textColor: const Color(0xFF10B981),
            showDivider: true,
          ),
          _buildInfoRow(
            title: 'QR Scan',
            statusLabel: 'Passed',
            textColor: const Color(0xFF10B981),
            showDivider: true,
          ),
          _buildInfoRow(
            title: 'Timesheet',
            statusLabel: 'Draft created',
            textColor: const Color(0xFF1F2937),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String title,
    required String statusLabel,
    required bool showDivider,
    required Color textColor,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.heading3.copyWith(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'DMSans'),
                    ),
                  ],
                ),
              ),
              // Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 6),
                    Text(
                      statusLabel,
                      style: AppTypography.caption.copyWith(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'DMSans',
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 76,
            endIndent: AppSpacing.lg,
            color: AppColors.border.withOpacity(0.4),
          ),
      ],
    );
  }

  Widget _buildTimesheetNotifier() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x383B5BDB),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: const Color(0xFFC7C4D8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/checkin_success_timesheetNotif.png',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Timesheet draft created for today. Please fill it before end of today.',
              style: TextStyle(
                color: Color(0xFF1A40C2),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoToHomeButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (isCheckOut) {
            // If checking out, go to the summary screen
            ref.read(dashboardStateProvider.notifier).setCheckedIn(false);
            context.go(AppRoutes.checkOutSuccess);
          } else {
            // Update isCheckedIn in dashboard_provider
            ref.read(dashboardStateProvider.notifier).setCheckedIn(true);
            // Navigate to dashboard
            context.go(AppRoutes.dashboard);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/checkin_success_homeButton.png',
              color: Colors.white,
              height: 15,
              width: 15,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              isCheckOut ? 'View Summary' : 'Go to Home',
              style: AppTypography.label.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoToTimesheetButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Update isCheckedIn in dashboard_provider
          ref.read(dashboardStateProvider.notifier).setCheckedIn(true);

          // Navigate to dashboard
          context.go(AppRoutes.dashboard);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(
              color: Color(0xFFC7D2FE),
            ),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/checkin_success_timesheetButton.png',
              color: const Color(0xFF4338CA),
              height: 15,
              width: 15,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Open Timesheet',
              style: AppTypography.label.copyWith(
                color: const Color(0xFF4338CA),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}