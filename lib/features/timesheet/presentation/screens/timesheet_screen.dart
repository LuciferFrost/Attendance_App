import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/timesheet_models.dart';
import '../providers/timesheet_providers.dart';

class TimesheetScreen extends ConsumerWidget {
  const TimesheetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final week = ref.watch(timesheetWeekProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _TimesheetAppBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WeekSummaryCard(week: week),
                    const SizedBox(height: AppSpacing.xxl),
                    _WeeklyProgressSection(week: week),
                    const SizedBox(height: AppSpacing.xxl),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg),
                      child: Text(
                        'Days',
                        style: AppTypography.heading1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _DaysList(week: week),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App Bar ────────────────────────────────────────────────────────────────

class _TimesheetAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF11141E),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back,
                color: Colors.white, size: 22),
          ),
          const Expanded(
            child: Text(
              'Timesheet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 22), // balance back arrow
        ],
      ),
    );
  }
}

// ─── Week Summary Card ──────────────────────────────────────────────────────

class _WeekSummaryCard extends StatelessWidget {
  final TimesheetWeek week;
  const _WeekSummaryCard({required this.week});

  @override
  Widget build(BuildContext context) {
    final logged = week.totalLogged;
    final remaining = week.remaining;
    final pct = week.completionPercent;

    final dateLabel =
        '${DateFormat('d MMM').format(week.weekStart)} – ${DateFormat('d MMM yyyy').format(week.weekEnd)}';

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F2E), Color(0xFF11141E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CURRENT WEEK',
                style: AppTypography.caption?.copyWith(
                  color: const Color(0xFF9CA3AF),
                  letterSpacing: 1.2,
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
              const Icon(Icons.calendar_today_outlined,
                  color: Color(0xFF9CA3AF), size: 18),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            dateLabel,
            style: const TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              _StatChip(
                value: _fmtHours(logged),
                label: 'Logged',
                valueColor: Colors.white,
              ),
              const SizedBox(width: AppSpacing.md),
              _StatChip(
                value: _fmtHours(remaining),
                label: 'Remaining',
                valueColor: const Color(0xFFF87171),
              ),
              const SizedBox(width: AppSpacing.md),
              _StatChip(
                value: '$pct%',
                label: 'Complete',
                valueColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtHours(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (m == 0) return '${h}h';
    return '${h}.${(m / 60 * 10).round()}h';
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  const _StatChip(
      {required this.value, required this.label, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md, horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2436),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize:10,
                fontWeight: FontWeight.w400,
                  color: const Color(0x66FFFFFF)
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Weekly Progress ────────────────────────────────────────────────────────

class _WeeklyProgressSection extends StatelessWidget {
  final TimesheetWeek week;
  const _WeeklyProgressSection({required this.week});

  @override
  Widget build(BuildContext context) {
    final logged = week.totalLogged;
    final required = week.weeklyRequired;
    final shortBy = week.remaining;
    final progress = (logged.inMinutes / required.inMinutes).clamp(0.0, 1.0);

    final loggedLabel =
        '${logged.inHours}.${(logged.inMinutes.remainder(60) / 60 * 10).round()}h';
    final requiredLabel =
        '${required.inHours}h';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly Progress', style: AppTypography.heading3),
              Text(
                '$loggedLabel / $requiredLabel',
                style: AppTypography.bodySmall?.copyWith(
                  color: AppColors.primary600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.neutral200,
              valueColor:
              const AlwaysStoppedAnimation<Color>(AppColors.primary600),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0H',
                  style: AppTypography.caption
                      ?.copyWith(color: AppColors.textSecondary)),
              if (shortBy > Duration.zero)
                Text(
                  'SHORT BY ${shortBy.inHours}.${(shortBy.inMinutes.remainder(60) / 60 * 10).round()}H',
                  style: AppTypography.caption
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              Text('${required.inHours}H',
                  style: AppTypography.caption
                      ?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Days List ───────────────────────────────────────────────────────────────

class _DaysList extends ConsumerWidget {
  final TimesheetWeek week;
  const _DaysList({required this.week});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final todayKey =
    DateTime(today.year, today.month, today.day);

    return Column(
      children: week.days.map((day) {
        final dayKey =
        DateTime(day.date.year, day.date.month, day.date.day);
        final isToday = dayKey == todayKey;
        final isFuture = dayKey.isAfter(todayKey);

        if (isFuture) return const SizedBox.shrink();

        return _DayRow(
          day: day,
          isToday: isToday,
          onTap: () {
            ref
                .read(selectedTimesheetDayProvider.notifier)
                .load(day.date);
            context.push(
              AppRoutes.timesheetDay,
              extra: {'date': day.date, 'isCurrentDay': isToday},
            );
          },
        );
      }).toList(),
    );
  }
}

class _DayRow extends StatelessWidget {
  final TimesheetDay day;
  final bool isToday;
  final VoidCallback onTap;

  const _DayRow({
    required this.day,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayAbbr = DateFormat('EEE').format(day.date).toUpperCase();
    final dayNum = day.date.day.toString();
    final dayName = DateFormat('EEEE').format(day.date);
    final entryCount = day.entries.length;
    final hours = day.totalLogged;
    final hoursLabel =
        '${hours.inHours.toString().padLeft(2, '0')}.${(hours.inMinutes.remainder(60) / 60 * 10).round()}h';

    final status = day.status;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: isToday ? const Color(0xFFF0F1FF) : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isToday ? AppColors.primary400 : Colors.white,
            width: isToday ? 1.5 : 1,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Accent bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A40C2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.radiusLg),
                    bottomLeft: Radius.circular(AppSpacing.radiusLg),
                  ),
                ),
              ),
              const SizedBox(width: 25), // Padding with the text

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.md,
                    bottom: AppSpacing.md,
                    right: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      // Date column
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xxxl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              dayAbbr,
                              style: AppTypography.caption?.copyWith(
                                color: const Color(0xFF6B7280),
                                fontFamily: 'DMSans',
                                fontWeight: FontWeight.w400,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dayNum,
                              style: AppTypography.heading2?.copyWith(
                                fontFamily: 'DMSans',
                                color: const Color(0xFF191C22),
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Day info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dayName,
                                style: AppTypography.heading3?.copyWith(
                                  color: const Color(0xFF191C22),
                                  fontFamily: 'DMSans',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                )),
                            const SizedBox(height: 2),
                            Text(
                              '$entryCount ${entryCount == 1 ? 'entry' : 'entries'} · ${_statusLabel(status)}',
                              style: AppTypography.caption?.copyWith(
                                color: const Color(0xFF6B7280),
                                fontFamily: 'DMSans',
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Hours + status badge
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              hoursLabel,
                              style: AppTypography.heading3?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontFamily: 'DMSans',
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _StatusBadge(status: status),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(TimesheetDayStatus s) {
    switch (s) {
      case TimesheetDayStatus.approved:
        return 'Approved';
      case TimesheetDayStatus.submitted:
        return 'Submitted';
      case TimesheetDayStatus.draft:
        return 'In progress';
      case TimesheetDayStatus.rejected:
        return 'Rejected';
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final TimesheetDayStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String text;
    Widget? dot;

    switch (status) {
      case TimesheetDayStatus.approved:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        text = 'Approved';
        dot = null;
        break;
      case TimesheetDayStatus.submitted:
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF1D4ED8);
        text = 'Submitted';
        dot = null;
        break;
      case TimesheetDayStatus.draft:
        bg = Colors.white;
        fg = AppColors.textSecondary;
        text = 'DRAFT';
        dot = Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 4),
          decoration: const BoxDecoration(
            color: AppColors.primary600,
            shape: BoxShape.circle,
          ),
        );
        break;
      case TimesheetDayStatus.rejected:
        bg = const Color(0xFFFFE4E6);
        fg = const Color(0xFFBE123C);
        text = 'Rejected';
        dot = null;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: status == TimesheetDayStatus.draft
            ? Border.all(color: AppColors.neutral300)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot != null) dot,
          Text(
            text,
            style: AppTypography.caption?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              fontFamily: 'DMSans',
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}