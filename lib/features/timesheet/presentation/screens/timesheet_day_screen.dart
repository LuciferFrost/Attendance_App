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

class TimesheetDayScreen extends ConsumerWidget {
  final DateTime date;
  final bool isCurrentDay;

  const TimesheetDayScreen({
    super.key,
    required this.date,
    required this.isCurrentDay,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(selectedTimesheetDayProvider) ??
        ref.read(timesheetRepositoryProvider).getDay(date);

    final hours = day.totalLogged;
    final required = day.requiredHours;
    final shortfall = day.shortfall;
    final progress = (hours.inMinutes / required.inMinutes).clamp(0.0, 1.0);
    final hasShortfall = day.hasShortfall;

    final dateLabel =
    DateFormat('EEEE, d MMMM yyyy').format(date).toUpperCase();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            _DayAppBar(title: 'Daily detail'),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dark summary card
                    _DaySummaryCard(
                      dateLabel: dateLabel,
                      hours: hours,
                      required: required,
                      shortfall: shortfall,
                      hasShortfall: hasShortfall,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Progress bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Day Progress',
                                  style: AppTypography.bodySmall?.copyWith(
                                      color: AppColors.textSecondary)),
                              Text(
                                '${hours.inHours}h / ${required.inHours}h',
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
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary600),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Entries header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('Entries',
                                  style: AppTypography.heading2?.copyWith(
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                '(${day.entries.length})',
                                style: AppTypography.heading2?.copyWith(
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          if (isCurrentDay)
                            _AddEntryButton(date: date, day: day),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Entry cards
                    ...day.entries.map((entry) => _EntryCard(
                      entry: entry,
                      date: date,
                      isEditable: isCurrentDay,
                    )),

                    // Warning banner (current day, has shortfall)
                    if (isCurrentDay && hasShortfall) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _ShortfallBanner(shortfall: shortfall),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom action buttons (current day only)
            if (isCurrentDay)
              _BottomActions(date: date, day: day),
          ],
        ),
      ),
    );
  }
}

// ─── App Bar ─────────────────────────────────────────────────────────────────

class _DayAppBar extends StatelessWidget {
  final String title;
  const _DayAppBar({required this.title});

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
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 22),
        ],
      ),
    );
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────

class _DaySummaryCard extends StatelessWidget {
  final String dateLabel;
  final Duration hours;
  final Duration required;
  final Duration shortfall;
  final bool hasShortfall;

  const _DaySummaryCard({
    required this.dateLabel,
    required this.hours,
    required this.required,
    required this.shortfall,
    required this.hasShortfall,
  });

  @override
  Widget build(BuildContext context) {
    final h = hours.inHours;
    final m = hours.inMinutes.remainder(60);

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xxl, horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F2E), Color(0xFF11141E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Column(
        children: [
          Text(
            dateLabel,
            style: AppTypography.caption?.copyWith(
              color: const Color(0xFF9CA3AF),
              letterSpacing: 1.2,
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Big mixed-size time display
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${h}h',
                  style: const TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: '${m.toString().padLeft(2, '0')}m',
                  style:  TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Required: ${required.inHours}h',
                style: AppTypography.bodySmall?.copyWith(
                    color: const Color(0xFF9CA3AF)),
              ),
              if (hasShortfall) ...[
                const Text('  •  ',
                    style: TextStyle(color: Color(0xFF9CA3AF))),
                Text(
                  'Shortfall: -${shortfall.inHours}h',
                  style: AppTypography.bodySmall?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Entry Card ───────────────────────────────────────────────────────────────

class _EntryCard extends ConsumerWidget {
  final TimesheetEntry entry;
  final DateTime date;
  final bool isEditable;

  const _EntryCard({
    required this.entry,
    required this.date,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h = entry.hours.inHours;
    final m = entry.hours.inMinutes.remainder(60);
    final hoursLabel = m == 0 ? '${h}h' : '${h}h ${m}m';

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project + hours
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.projectName,
                      style: AppTypography.heading3
                          ?.copyWith(fontWeight: FontWeight.w500,
                      fontFamily: 'DMSans',
                      fontSize: 15,),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${entry.activity} → ${entry.subActivity}',
                      style: AppTypography.caption?.copyWith(
                          color: AppColors.textSecondary,
                      fontFamily: 'DMSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Text(
                hoursLabel,
                style: AppTypography.heading3?.copyWith(
                  color: AppColors.primary600,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'DMMono',
                  fontSize: 17,
                ),
              ),
            ],
          ),

          // Remarks
          if (entry.remarks != null && entry.remarks!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 3,
                        color: const Color(0xFF3B5BDB),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          child: Text(
                            entry.remarks!,
                            style: AppTypography.body?.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.5,
                              fontFamily: 'DMSans',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Edit / Delete buttons (editable mode)
          if (isEditable) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _IconBtn(
                  icon: Icons.edit_outlined,
                  onTap: () {
                    final currentDay = ref.read(selectedTimesheetDayProvider) ??
                        ref.read(timesheetRepositoryProvider).getDay(date);
                    context.push(
                      AppRoutes.timesheetEditEntry,
                      extra: {
                        'date': date,
                        'day': currentDay,
                        'entry': entry,
                      },
                    );
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                _IconBtn(
                  icon: Icons.delete_outline,
                  onTap: () => _confirmDelete(context, ref),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final day = ref.read(selectedTimesheetDayProvider) ??
        ref.read(timesheetRepositoryProvider).getDay(date);
    final hoursAfter = day.totalLogged - entry.hours;
    final shortfallAfter = day.requiredHours - hoursAfter;

    await showDialog<void>(
      context: context,
      builder: (_) => _DeleteEntryDialog(
        entry: entry,
        date: date,
        hoursAfter: hoursAfter,
        shortfallAfter: shortfallAfter,
        onConfirm: () {
          ref
              .read(selectedTimesheetDayProvider.notifier)
              .deleteEntry(date, entry.id);
          ref.read(timesheetWeekProvider.notifier).refresh();
        },
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: const Color(0xFFE3E7EF),
          )
        ),
        child: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
    );
  }
}

// ─── Delete Dialog ────────────────────────────────────────────────────────────

class _DeleteEntryDialog extends StatelessWidget {
  final TimesheetEntry entry;
  final DateTime date;
  final Duration hoursAfter;
  final Duration shortfallAfter;
  final VoidCallback onConfirm;

  const _DeleteEntryDialog({
    required this.entry,
    required this.date,
    required this.hoursAfter,
    required this.shortfallAfter,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final dayLabel =
    DateFormat('EEEE d MMM').format(date);
    final beforeH = (hoursAfter + entry.hours).inHours;
    final afterH = hoursAfter.inHours;
    final entryH = entry.hours.inHours;

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // X button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close,
                    color: AppColors.textSecondary, size: 20),
              ),
            ),
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4E6),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: const Icon(Icons.delete_outline,
                  color: Color(0xFFBE123C), size: 24),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Delete Entry?',
                style: AppTypography.heading2
                    ?.copyWith(fontWeight: FontWeight.w600,
                fontFamily: 'PlayfairDisplay',
                fontSize: 20)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This entry will be permanently remove ${entryH}h from $dayLabel. This action cannot be undo.',
              textAlign: TextAlign.center,
              style: AppTypography.body
                  ?.copyWith(color: AppColors.textSecondary, height: 1.5, fontFamily: 'DMSans',fontSize: 14, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Impact box
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border:
                Border.all(color: const Color(0xFFFFCDD2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IMPACT AFTER DELETION',
                    style: AppTypography.caption?.copyWith(
                      color: const Color(0xFFBE123C),
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'DMSans',
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        '${beforeH}h',
                        style: AppTypography.heading2
                            ?.copyWith(fontWeight: FontWeight.w500,fontFamily: 'DMMono',fontSize: 20),
                      ),
                      const Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                        child: Icon(Icons.arrow_forward,
                            size: 16, color: AppColors.textSecondary),
                      ),
                      Text(
                        '${afterH}h',
                        style: AppTypography.heading2?.copyWith(
                          color: const Color(0xFFFA5252),
                            fontWeight: FontWeight.w500,fontFamily: 'DMMono',fontSize: 20
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(
                              AppSpacing.radiusFull),
                        ),
                        child: Text(
                          '-${entryH}h shortfall',
                          style: AppTypography.caption?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'DMSans',
                            fontSize: 16
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Delete button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: Colors.white),
                label: const Text('Delete Entry',
                    style: TextStyle(color: Colors.white, fontFamily: 'DMSans',fontSize: 16, fontWeight: FontWeight.w400)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFA5252),
                  padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd)),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.neutral100,
                  padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd)),
                ),
                child: Text('Cancel',
                    style: AppTypography.body
                        ?.copyWith(color: AppColors.textSecondary,fontFamily: 'DMSans',fontSize: 16, fontWeight: FontWeight.w400)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shortfall Banner ─────────────────────────────────────────────────────────

class _ShortfallBanner extends StatelessWidget {
  final Duration shortfall;
  const _ShortfallBanner({required this.shortfall});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDDB6),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: const Color(0x4DFFB95B)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline,
              color: Color(0xFF704600), size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'You need ${shortfall.inHours} more ${shortfall.inHours == 1 ? 'hour' : 'hours'} to complete today\'s required attendance.',
              style: AppTypography.bodySmall?.copyWith(
                color: const Color(0xFF2A1800),
                fontWeight: FontWeight.w500,
                fontFamily: 'DMSans',
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add Entry Button ─────────────────────────────────────────────────────────

class _AddEntryButton extends StatelessWidget {
  final DateTime date;
  final TimesheetDay day;

  const _AddEntryButton({required this.date, required this.day});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => context.push(
        AppRoutes.timesheetAddEntry,
        extra: {'date': date, 'day': day},
      ),
      icon: const Icon(Icons.add, size: 16, color: Colors.white),
      label: const Text('Add Entry',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B5BDB),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        elevation: 0,
      ),
    );
  }
}

// ─── Bottom Actions ───────────────────────────────────────────────────────────

class _BottomActions extends ConsumerWidget {
  final DateTime date;
  final TimesheetDay day;

  const _BottomActions({required this.date, required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Save Draft
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ref
                    .read(selectedTimesheetDayProvider.notifier)
                    .saveDraft(date);
                ref.read(timesheetWeekProvider.notifier).refresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Draft saved')),
                );
              },
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Save Draft', style: TextStyle(
                   fontWeight: FontWeight.w500,fontFamily: 'DMSans',fontSize: 15,)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary600,
                side: BorderSide(color: AppColors.primary600),
                padding:
                const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMd)),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Submit
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: day.entries.isEmpty
                  ? null
                  : () {
                ref
                    .read(selectedTimesheetDayProvider.notifier)
                    .submitDay(date);
                ref.read(timesheetWeekProvider.notifier).refresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                      Text('Timesheet submitted successfully')),
                );
                context.pop();
              },
              icon: Image.asset('assets/images/timesheet_submit.png', height: 16, width: 19),
              label: const Text('Submit Timesheet',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500,fontFamily: 'DMSans',fontSize: 15,)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B5BDB),
                padding:
                const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMd)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}