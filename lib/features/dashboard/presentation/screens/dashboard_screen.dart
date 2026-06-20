import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../attendance/presentation/providers/checkin_providers.dart';
import '../../../attendance/domain/entities/checkin_models.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayStatusAsync = ref.watch(todayCheckInStatusProvider('emp_001'));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header with title
            Padding(
              padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Employee',
                    style: AppTypography.displayHero.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Your attendance dashboard',
                    style: AppTypography.body.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Quick Check-in Card
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: _buildQuickCheckInCard(context, isDark, todayStatusAsync),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Status Cards
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: _buildStatusCards(isDark, todayStatusAsync),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Additional Dashboard Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                children: [
                  Text(
                    'Recent Activity',
                    style: AppTypography.heading2.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildActivityItem(
                    isDark,
                    'Check-in recorded',
                    'Today at 09:15 AM',
                    Icons.check_circle,
                    AppColors.secondary600,
                  ),
                  _buildActivityItem(
                    isDark,
                    'Shift started',
                    'General (09:00 AM - 06:00 PM)',
                    Icons.schedule,
                    AppColors.primary600,
                  ),
                  _buildActivityItem(
                    isDark,
                    'Location verified',
                    'Within office geofence',
                    Icons.location_on,
                    AppColors.info,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build quick check-in card with navigation button
  Widget _buildQuickCheckInCard(
      BuildContext context,
      bool isDark,
      AsyncValue<CheckInStatus> statusAsync,
      ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary600,
            AppColors.primary700,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary600.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Check-in',
            style: AppTypography.heading2.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          statusAsync.when(
            data: (status) => Text(
              status.hasCheckedIn
                  ? '✓ You have checked in today'
                  : 'Start your day with a check-in',
              style: AppTypography.body.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            loading: () => Text(
              'Loading status...',
              style: AppTypography.body.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            error: (error, _) => Text(
              'Error loading status',
              style: AppTypography.body.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.checkIn),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary700,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
              icon: const Icon(Icons.location_on_rounded),
              label: Text(
                'Go to Check-in',
                style: AppTypography.buttonText.copyWith(
                  color: AppColors.primary700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build status information cards
  Widget _buildStatusCards(bool isDark, AsyncValue<CheckInStatus> statusAsync) {
    return statusAsync.when(
      data: (status) => Column(
        children: [
          _buildStatusCard(
            isDark,
            'Office Location',
            status.officeLocation ?? 'N/A',
            Icons.location_on_outlined,
            AppColors.primary600,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildStatusCard(
            isDark,
            'Shift Timing',
            status.shiftTimings,
            Icons.schedule_rounded,
            AppColors.secondary600,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildStatusCard(
            isDark,
            'GPS Permission',
            status.gpsPermissionGranted ? 'Granted' : 'Not Granted',
            Icons.gps_fixed_rounded,
            status.gpsPermissionGranted ? AppColors.secondary600 : AppColors.error,
          ),
        ],
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => Text('Error loading status'),
    );
  }

  /// Build individual status card
  Widget _buildStatusCard(
      bool isDark,
      String title,
      String value,
      IconData icon,
      Color iconColor,
      ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceSecondary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.label.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: AppTypography.heading3.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build activity list item
  Widget _buildActivityItem(
      bool isDark,
      String title,
      String subtitle,
      IconData icon,
      Color iconColor,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceSecondary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.heading3.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}