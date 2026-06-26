import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/repositories/timesheet_repository.dart';
import '../../domain/entities/timesheet_models.dart';
import '../providers/timesheet_providers.dart';

class TimesheetEntryScreen extends ConsumerStatefulWidget {
  /// The day this entry belongs to.
  final DateTime date;

  /// Current day's data — used to compute the "already logged" summary.
  final TimesheetDay day;

  /// When non-null, we are editing an existing entry.
  final TimesheetEntry? existingEntry;

  const TimesheetEntryScreen({
    super.key,
    required this.date,
    required this.day,
    this.existingEntry,
  });

  bool get isEditing => existingEntry != null;

  @override
  ConsumerState<TimesheetEntryScreen> createState() =>
      _TimesheetEntryScreenState();
}

class _TimesheetEntryScreenState extends ConsumerState<TimesheetEntryScreen> {
  late String _project;
  final _customProjectCtrl = TextEditingController();
  final _activityCtrl = TextEditingController();
  final _subActivityCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();

  // Hours / minutes stored separately for the HH:MM input
  int _hours = 0;
  int _minutes = 0;

  final _hoursCtrl = TextEditingController();
  final _minutesCtrl = TextEditingController();

  bool _billable = true;

  @override
  void initState() {
    super.initState();
    final e = widget.existingEntry;
    if (e != null) {
      _project = e.projectName;
      _customProjectCtrl.text = e.customProjectName ?? '';
      _activityCtrl.text = e.activity;
      _subActivityCtrl.text = e.subActivity;
      _remarksCtrl.text = e.remarks ?? '';
      _hours = e.hours.inHours;
      _minutes = e.hours.inMinutes.remainder(60);
      _billable = e.billable;
    } else {
      _project = kTimesheetProjects.first;
    }
    _hoursCtrl.text = '${_hours.toString().padLeft(2, '0')}:${_minutes.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _customProjectCtrl.dispose();
    _activityCtrl.dispose();
    _subActivityCtrl.dispose();
    _remarksCtrl.dispose();
    _hoursCtrl.dispose();
    _minutesCtrl.dispose();
    super.dispose();
  }

  Duration get _entryDuration => Duration(hours: _hours, minutes: _minutes);

  Duration get _alreadyLogged {
    final existing = widget.existingEntry;
    if (existing == null) return widget.day.totalLogged;
    // Exclude the entry being edited from "already logged"
    return widget.day.entries
        .where((e) => e.id != existing.id)
        .fold(Duration.zero, (sum, e) => sum + e.hours);
  }

  Duration get _totalAfterSave => _alreadyLogged + _entryDuration;

  Duration get _remaining =>
      widget.day.requiredHours - _alreadyLogged;

  bool get _resolvesShortfall =>
      widget.isEditing &&
          widget.existingEntry != null &&
          _totalAfterSave >= widget.day.requiredHours &&
          _alreadyLogged < widget.day.requiredHours;

  /// The hours this entry needs to be set to in order to resolve the shortfall.
  /// = existing entry hours + remaining shortfall after excluding this entry.
  int get _hoursNeededToResolve {
    final shortfall = widget.day.requiredHours - _alreadyLogged;
    return shortfall.inHours;
  }

  void _onTimeChanged(String v) {
    final parts = v.split(':');
    int h = 0;
    int m = 0;
    if (parts.isNotEmpty) h = int.tryParse(parts[0]) ?? 0;
    if (parts.length > 1) m = (int.tryParse(parts[1]) ?? 0).clamp(0, 59);

    setState(() {
      _hours = h;
      _minutes = m;
    });
  }

  void _save() {
    if (_subActivityCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in the Sub Activity')),
      );
      return;
    }
    if (_entryDuration == Duration.zero) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid duration')),
      );
      return;
    }

    final entry = TimesheetEntry(
      id: widget.existingEntry?.id ??
          'entry_${DateTime.now().millisecondsSinceEpoch}',
      projectName: _project,
      customProjectName:
      _project == 'Other' ? _customProjectCtrl.text.trim() : null,
      activity: _activityCtrl.text.trim(),
      subActivity: _subActivityCtrl.text.trim(),
      hours: _entryDuration,
      remarks: _remarksCtrl.text.trim().isEmpty
          ? null
          : _remarksCtrl.text.trim(),
      billable: _billable,
    );

    ref
        .read(selectedTimesheetDayProvider.notifier)
        .saveEntry(widget.date, entry);
    ref.read(timesheetWeekProvider.notifier).refresh();

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel =
    DateFormat('EEEE, d MMMM yyyy').format(widget.date);
    final remainingH = _remaining.inHours;
    final remainingM = _remaining.inMinutes.remainder(60);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _EntryAppBar(
                title: widget.isEditing ? 'Edit Entry' : 'Add Entry'),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    top: AppSpacing.lg,
                    bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Edit-mode info banner
                    if (widget.isEditing) ...[
                      _EditInfoBanner(date: widget.date),
                      const SizedBox(height: AppSpacing.xl),
                    ],

                    // Date field (only for Add mode)
                    if (!widget.isEditing) ...[
                      _FieldLabel('DATE *'),
                      const SizedBox(height: AppSpacing.xs),
                      _DateField(
                        date: widget.date,
                        onTap: () {}, // date is fixed for the day
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Project dropdown
                    _FieldLabel('PROJECT / PRODUCT${widget.isEditing ? '' : ' *'}'),
                    const SizedBox(height: AppSpacing.xs),
                    _ProjectDropdown(
                      value: _project,
                      onChanged: (v) => setState(() => _project = v!),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Custom project name (only when "Other" selected)
                    if (_project == 'Other') ...[
                      _FieldLabel('PROJECT NAME *'),
                      const SizedBox(height: AppSpacing.xs),
                      _TextInput(
                        controller: _customProjectCtrl,
                        hint: 'Enter project name',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Activity
                    _FieldLabel('ACTIVITY'),
                    const SizedBox(height: AppSpacing.xs),
                    _TextInput(
                      controller: _activityCtrl,
                      hint: 'e.g. Development',
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Sub activity
                    _FieldLabel('SUB ACTIVITY *'),
                    const SizedBox(height: AppSpacing.xs),
                    _TextInput(
                      controller: _subActivityCtrl,
                      hint: 'Describe...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Total hours
                    _FieldLabel('Total hours'),
                    const SizedBox(height: AppSpacing.xs),
                    _TextInput(
                      controller: _hoursCtrl,
                      hint: '03:00',
                      onChanged: _onTimeChanged,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if (!widget.isEditing)
                      Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${remainingH}h ${remainingM}m remaining for today. Max single entry: 9h.',
                            style: AppTypography.caption?.copyWith(
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),

                    // Resolve shortfall hint (edit mode only)
                    if (widget.isEditing && widget.existingEntry != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 14, color: Color(0xFF15803D)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Editing ${widget.existingEntry!.hours.inHours}h → ${_hoursNeededToResolve}h will resolve the shortfall for this day.',
                              style: AppTypography.caption?.copyWith(
                                  color: const Color(0xFF15803D)),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: AppSpacing.lg),

                    // Remarks (add mode only)
                    if (!widget.isEditing) ...[
                      _FieldLabel('REMARKS (OPTIONAL)'),
                      const SizedBox(height: AppSpacing.xs),
                      _TextInput(
                        controller: _remarksCtrl,
                        hint: 'Any additional notes...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Day summary preview (add mode only)
                    if (!widget.isEditing)
                      _DaySummaryPreview(
                        alreadyLogged: _alreadyLogged,
                        thisEntry: _entryDuration,
                        total: _totalAfterSave,
                        required: widget.day.requiredHours,
                      ),

                    // Billable toggle (add mode only)
                    if (!widget.isEditing) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _BillableToggle(
                        billable: _billable,
                        onChanged: (v) => setState(() => _billable = v),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom buttons
            _EntryBottomBar(
              isEditing: widget.isEditing,
              onSave: _save,
              onDelete: widget.isEditing
                  ? () => context.pop() // delete handled by day screen
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _EntryAppBar extends StatelessWidget {
  final String title;
  const _EntryAppBar({required this.title});

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
            child:
            const Icon(Icons.arrow_back, color: Colors.white, size: 22),
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

// ─── Edit Info Banner ─────────────────────────────────────────────────────────

class _EditInfoBanner extends StatelessWidget {
  final DateTime date;
  const _EditInfoBanner({required this.date});

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('EEE d MMM').format(date);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.edit_outlined,
              size: 16, color: AppColors.primary600),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Editing entry from $label. Update fields and tap Update to save changes.',
              style: AppTypography.body?.copyWith(
                  color: AppColors.primary700, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Date Field ───────────────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;
  const _DateField({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(date),
              style: AppTypography.body?.copyWith(
                  fontWeight: FontWeight.w600),
            ),
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: AppColors.primary600),
          ],
        ),
      ),
    );
  }
}

// ─── Field label ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.caption?.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 0.8,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ─── Text Input ───────────────────────────────────────────────────────────────

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const _TextInput({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      style: AppTypography.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
        AppTypography.body?.copyWith(color: AppColors.textTertiary),
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary600, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Project Dropdown ─────────────────────────────────────────────────────────

class _ProjectDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _ProjectDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      style: AppTypography.body,
      decoration: InputDecoration(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide:
          const BorderSide(color: AppColors.primary600, width: 1.5),
        ),
      ),
      items: kTimesheetProjects
          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
          .toList(),
    );
  }
}

// ─── Hours Input ──────────────────────────────────────────────────────────────

class _HoursInput extends StatelessWidget {
  final TextEditingController hoursCtrl;
  final TextEditingController minutesCtrl;
  final ValueChanged<String> onHoursChanged;
  final ValueChanged<String> onMinutesChanged;

  const _HoursInput({
    required this.hoursCtrl,
    required this.minutesCtrl,
    required this.onHoursChanged,
    required this.onMinutesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      borderSide: const BorderSide(color: AppColors.primary400, width: 1.5),
    );

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: hoursCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            onChanged: onHoursChanged,
            textAlign: TextAlign.center,
            style: AppTypography.heading2
                ?.copyWith(fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.md),
              border: border,
              enabledBorder: border,
              focusedBorder: border,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(':',
              style: AppTypography.heading1
                  ?.copyWith(color: AppColors.textSecondary)),
        ),
        Expanded(
          child: TextField(
            controller: minutesCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            onChanged: onMinutesChanged,
            textAlign: TextAlign.center,
            style: AppTypography.heading2
                ?.copyWith(fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.md),
              border: border,
              enabledBorder: border,
              focusedBorder: border,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Day Summary Preview ──────────────────────────────────────────────────────

class _DaySummaryPreview extends StatelessWidget {
  final Duration alreadyLogged;
  final Duration thisEntry;
  final Duration total;
  final Duration required;

  const _DaySummaryPreview({
    required this.alreadyLogged,
    required this.thisEntry,
    required this.total,
    required this.required,
  });

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }

  @override
  Widget build(BuildContext context) {
    final isOver = total > required;
    final totalColor = isOver
        ? AppColors.error
        : total >= required
        ? const Color(0xFF15803D)
        : AppColors.primary600;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DAY SUMMARY AFTER SAVING',
            style: AppTypography.caption?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SummaryRow(
            label: 'Already logged',
            value: _fmt(alreadyLogged),
            valueColor: AppColors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.xs),
          _SummaryRow(
            label: 'This entry',
            value: '+${_fmt(thisEntry)}',
            valueColor: AppColors.primary600,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(color: AppColors.neutral200),
          ),
          _SummaryRow(
            label: 'Total',
            value: '${_fmt(total)} / ${required.inHours}h req.',
            valueColor: totalColor,
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? AppTypography.body?.copyWith(fontWeight: FontWeight.w700)
              : AppTypography.body,
        ),
        Text(
          value,
          style: AppTypography.body?.copyWith(
            color: valueColor,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Billable Toggle ──────────────────────────────────────────────────────────

class _BillableToggle extends StatelessWidget {
  final bool billable;
  final ValueChanged<bool> onChanged;

  const _BillableToggle(
      {required this.billable, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ToggleOption(
          label: 'Billable',
          selected: billable,
          icon: Icons.check,
          onTap: () => onChanged(true),
        ),
        const SizedBox(width: AppSpacing.sm),
        _ToggleOption(
          label: 'Non-Billable',
          selected: !billable,
          icon: null,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: selected ? const Color(0xFF15803D) : AppColors.neutral200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null && selected) ...[
              Icon(icon, size: 14, color: const Color(0xFF15803D)),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTypography.body?.copyWith(
                color: selected
                    ? const Color(0xFF15803D)
                    : AppColors.textSecondary,
                fontWeight:
                selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom Bar ───────────────────────────────────────────────────────────────

class _EntryBottomBar extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onSave;
  final VoidCallback? onDelete;

  const _EntryBottomBar({
    required this.isEditing,
    required this.onSave,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.check, size: 18, color: Colors.white),
              label: Text(
                isEditing ? 'Update Entry' : 'Save Entry',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary700,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMd)),
                elevation: 0,
              ),
            ),
          ),
          if (isEditing) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: Colors.white),
                label: const Text('Delete This Entry',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFA5252),
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
        ],
      ),
    );
  }
}