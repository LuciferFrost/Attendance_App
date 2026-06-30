import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

enum _TimesheetStatus { pending, approved, rejected }

class _TimesheetEntry {
  final String project;
  final String task;
  final String remarks;
  final double hours;

  const _TimesheetEntry({
    required this.project,
    required this.task,
    required this.remarks,
    required this.hours,
  });
}

class _DayEntry {
  final String day;
  final int entryCount;
  final double totalHours;
  final bool isShortLeave;
  final List<_TimesheetEntry> entries;

  const _DayEntry({
    required this.day,
    required this.entryCount,
    required this.totalHours,
    this.isShortLeave = false,
    required this.entries,
  });
}

class _Timesheet {
  final String name;
  final String initials;
  final String empId;
  final String week;
  final double loggedHours;
  final double targetHours;
  final _TimesheetStatus status;
  final String? shortfall;
  final String? note;
  final List<_DayEntry> days;

  const _Timesheet({
    required this.name,
    required this.initials,
    required this.empId,
    required this.week,
    required this.loggedHours,
    required this.targetHours,
    required this.status,
    this.shortfall,
    this.note,
    required this.days,
  });
}

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

final _sampleEntries = [
  const _TimesheetEntry(
    project: 'CraftEdge Platform',
    task: 'Feature Dev',
    remarks: 'Completed 3 components, pending review for card module',
    hours: 4,
  ),
  const _TimesheetEntry(
    project: 'HRMS Module',
    task: 'Bug Fixes',
    remarks: 'Completed 3 components, pending review for card module',
    hours: 3,
  ),
  const _TimesheetEntry(
    project: 'Internal',
    task: 'Team Meeting',
    remarks: 'Completed 3 components, pending review for card module',
    hours: 2,
  ),
];

final _mockTimesheets = [
  _Timesheet(
    name: 'Priya Ramesh',
    initials: 'PR',
    empId: 'EMP-0042',
    week: 'Week 2, Jun 2026',
    loggedHours: 45,
    targetHours: 45,
    status: _TimesheetStatus.approved,
    days: [
      _DayEntry(day: 'Monday', entryCount: 3, totalHours: 9, entries: _sampleEntries),
      _DayEntry(day: 'Tuesday', entryCount: 3, totalHours: 9, entries: _sampleEntries),
      _DayEntry(day: 'Wednesday', entryCount: 3, totalHours: 9, entries: _sampleEntries),
      _DayEntry(day: 'Thursday', entryCount: 3, totalHours: 9, entries: _sampleEntries),
      _DayEntry(day: 'Friday', entryCount: 3, totalHours: 9, entries: _sampleEntries),
    ],
  ),
  _Timesheet(
    name: 'Aditya Kumar',
    initials: 'AK',
    empId: 'EMP-0031',
    week: 'Week 2, Jun 2026',
    loggedHours: 37,
    targetHours: 45,
    status: _TimesheetStatus.approved,
    shortfall: '-8h',
    days: [
      _DayEntry(day: 'Monday', entryCount: 3, totalHours: 9, entries: _sampleEntries),
      _DayEntry(day: 'Tuesday', entryCount: 3, totalHours: 7, isShortLeave: true, entries: _sampleEntries),
      _DayEntry(day: 'Wednesday', entryCount: 2, totalHours: 7, isShortLeave: true, entries: _sampleEntries),
      _DayEntry(day: 'Thursday', entryCount: 3, totalHours: 7, isShortLeave: true, entries: _sampleEntries),
      _DayEntry(day: 'Friday', entryCount: 2, totalHours: 7, isShortLeave: true, entries: _sampleEntries),
    ],
  ),
  _Timesheet(
    name: 'Divya Venkat',
    initials: 'DV',
    empId: 'EMP-0078',
    week: 'Week 2, Jun 2026',
    loggedHours: 43.5,
    targetHours: 45,
    status: _TimesheetStatus.pending,
    note: 'Short leave',
    days: [
      _DayEntry(day: 'Monday', entryCount: 3, totalHours: 9, entries: _sampleEntries),
      _DayEntry(day: 'Tuesday', entryCount: 3, totalHours: 9, entries: _sampleEntries),
      _DayEntry(day: 'Wednesday', entryCount: 3, totalHours: 9, entries: _sampleEntries),
      _DayEntry(day: 'Thursday', entryCount: 3, totalHours: 7, isShortLeave: true, entries: _sampleEntries),
      _DayEntry(day: 'Friday', entryCount: 3, totalHours: 9, entries: _sampleEntries),
    ],
  ),
  _Timesheet(
    name: 'Nikhil Kapoor',
    initials: 'NK',
    empId: 'EMP-0055',
    week: 'Week 2, Jun 2026',
    loggedHours: 31.5,
    targetHours: 45,
    status: _TimesheetStatus.rejected,
    note: 'Rejected — remarks added',
    days: [
      _DayEntry(day: 'Monday', entryCount: 3, totalHours: 9, entries: _sampleEntries),
      _DayEntry(day: 'Tuesday', entryCount: 2, totalHours: 7, isShortLeave: true, entries: _sampleEntries),
      _DayEntry(day: 'Wednesday', entryCount: 2, totalHours: 7, isShortLeave: true, entries: _sampleEntries),
      _DayEntry(day: 'Thursday', entryCount: 1, totalHours: 5, isShortLeave: true, entries: _sampleEntries),
      _DayEntry(day: 'Friday', entryCount: 1, totalHours: 3.5, isShortLeave: true, entries: _sampleEntries),
    ],
  ),
  _Timesheet(
    name: 'Rohit Sharma',
    initials: 'RS',
    empId: 'EMP-0019',
    week: 'Week 2, Jun 2026',
    loggedHours: 38.5,
    targetHours: 45,
    status: _TimesheetStatus.pending,
    days: [
      _DayEntry(day: 'Monday', entryCount: 3, totalHours: 9, entries: _sampleEntries),
      _DayEntry(day: 'Tuesday', entryCount: 3, totalHours: 9, entries: _sampleEntries),
      _DayEntry(day: 'Wednesday', entryCount: 3, totalHours: 9, entries: _sampleEntries),
      _DayEntry(day: 'Thursday', entryCount: 2, totalHours: 7, isShortLeave: true, entries: _sampleEntries),
      _DayEntry(day: 'Friday', entryCount: 1, totalHours: 4.5, isShortLeave: true, entries: _sampleEntries),
    ],
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final _selectedFilterProvider = StateProvider<_TimesheetStatus?>((ref) => null);
final _timesheetsProvider = StateProvider<List<_Timesheet>>((ref) => _mockTimesheets);

// ---------------------------------------------------------------------------
// List screen
// ---------------------------------------------------------------------------

class TimesheetApprovalsScreen extends ConsumerWidget {
  const TimesheetApprovalsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(_selectedFilterProvider);
    final timesheets = ref.watch(_timesheetsProvider);

    final filtered = filter == null
        ? timesheets
        : timesheets.where((t) => t.status == filter).toList();

    final pendingCount = timesheets.where((t) => t.status == _TimesheetStatus.pending).length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildFilterBar(context, ref, filter),
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _buildCard(context, ref, filtered[i], pendingCount),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(color: Color(0xFF11141E)),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          ),
          Center(
            child: Text(
              'Timesheet review',
              style: const TextStyle(
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

  Widget _buildFilterBar(BuildContext context, WidgetRef ref, _TimesheetStatus? selected) {
    final filters = <_TimesheetStatus?>[null, _TimesheetStatus.pending, _TimesheetStatus.approved, _TimesheetStatus.rejected];
    final labels = ['All', 'Pending', 'Approved', 'Rejected'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(filters.length, (i) {
            final isActive = selected == filters[i];
            return Padding(
              padding: EdgeInsets.only(right: i < filters.length - 1 ? 8 : 0),
              child: GestureDetector(
                onTap: () => ref.read(_selectedFilterProvider.notifier).state = filters[i],
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF3B5BDB) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? const Color(0xFF3B5BDB) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, _Timesheet t, int pendingCount) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProviderScope(
              overrides: [],
              child: _TimesheetDetailScreen(timesheet: t),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            _Avatar(initials: t.initials),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.name,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${t.week} · ${t.loggedHours}h logged',
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  if (t.note != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      t.note!,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            _StatusChip(status: t.status, hours: t.loggedHours, shortfall: t.shortfall),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text(
        'No timesheets here',
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 14,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail screen
// ---------------------------------------------------------------------------

class _TimesheetDetailScreen extends StatefulWidget {
  final _Timesheet timesheet;
  const _TimesheetDetailScreen({required this.timesheet});

  @override
  State<_TimesheetDetailScreen> createState() => _TimesheetDetailScreenState();
}

class _TimesheetDetailScreenState extends State<_TimesheetDetailScreen> {
  _DayEntry? _expandedDay;

  @override
  Widget build(BuildContext context) {
    final t = widget.timesheet;
    final shortBy = t.targetHours - t.loggedHours;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(color: Color(0xFF11141E)),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                  ),
                  Center(
                    child: Text(
                      'Timesheet review',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Employee info
                    Row(
                      children: [
                        _Avatar(initials: t.initials, size: 48),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.name,
                                style: const TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF3B5BDB),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${t.empId} · ${t.week}',
                                style: const TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _StatusChip(status: t.status, hours: null),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${t.loggedHours.toStringAsFixed(t.loggedHours % 1 == 0 ? 0 : 1)}h 00m',
                                    style: const TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 12,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Weekly progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Weekly Progress',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${t.loggedHours}h',
                                style: const TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF3B5BDB),
                                ),
                              ),
                              TextSpan(
                                text: ' / ${t.targetHours.toInt()}h',
                                style: const TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 14,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (t.loggedHours / t.targetHours).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B5BDB)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('0H', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFF94A3B8))),
                        if (shortBy > 0)
                          Text(
                            'SHORT BY ${shortBy}H',
                            style: const TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFFEF4444), fontWeight: FontWeight.w600),
                          ),
                        Text(
                          '${t.targetHours.toInt()}H',
                          style: const TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Day entries
                    ...t.days.map((day) => _buildDayRow(context, day)),
                  ],
                ),
              ),
            ),

            // Bottom action buttons
            if (t.status == _TimesheetStatus.pending)
              _buildActionBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDayRow(BuildContext context, _DayEntry day) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _expandedDay = _expandedDay == day ? null : day;
            });
          },
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B5BDB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.day,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${day.entryCount} entries · ${day.totalHours % 1 == 0 ? day.totalHours.toInt() : day.totalHours} hrs${day.isShortLeave ? ' (short leave)' : ' complete'}',
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 14, color: Color(0xFFD97706)),
                    const SizedBox(width: 4),
                    Text(
                      '1h 45m',
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        color: Color(0xFFD97706),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_expandedDay == day)
          _DayDetailSheet(
            day: day,
            onClose: () => setState(() => _expandedDay = null),
            onApprove: () {
              setState(() => _expandedDay = null);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${day.day} approved'),
                  backgroundColor: const Color(0xFF059669),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            onReject: () => _showRejectDialog(context, day.day),
          ),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
      ],
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: 'Approve',
              icon: Icons.check,
              color: const Color(0xFF059669),
              onTap: () => _handleApprove(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              label: 'Reject',
              icon: Icons.close,
              color: const Color(0xFFEF4444),
              onTap: () => _showRejectDialog(context, null),
            ),
          ),
        ],
      ),
    );
  }

  void _handleApprove(BuildContext context) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.timesheet.name}\'s timesheet approved'),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String? dayLabel) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  dayLabel != null ? 'Reject $dayLabel' : 'Reject Timesheet',
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Remarks (required)',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add a reason for rejection…',
                hintStyle: const TextStyle(fontFamily: 'DMSans', color: Color(0xFFCBD5E1)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF3B5BDB)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (controller.text.trim().isEmpty) return;
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Timesheet rejected with remarks'),
                      backgroundColor: const Color(0xFFEF4444),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text(
                  'Confirm Rejection',
                  style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Day detail sheet (inline expansion)
// ---------------------------------------------------------------------------

class _DayDetailSheet extends StatelessWidget {
  final _DayEntry day;
  final VoidCallback onClose;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _DayDetailSheet({
    required this.day,
    required this.onClose,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final totalH = day.entries.fold<double>(0, (sum, e) => sum + e.hours);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sheet header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Timesheet Entries',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${totalH.toInt()}h 00m',
                              style: const TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF059669),
                              ),
                            ),
                            TextSpan(
                              text: ' / ${day.totalHours.toInt()}h',
                              style: const TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 13,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 20),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Entries list
          ...day.entries.map((e) => _buildEntryRow(e)),

          const SizedBox(height: 12),

          // Approve / Reject
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Approve',
                    icon: Icons.check,
                    color: const Color(0xFF059669),
                    onTap: onApprove,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    label: 'Reject',
                    icon: Icons.close,
                    color: const Color(0xFFEF4444),
                    onTap: onReject,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryRow(_TimesheetEntry e) {
    return Column(
      children: [
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${e.project} · ${e.task}',
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sub: ${e.task}',
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Remarks: ${e.remarks}',
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${e.hours.toInt()}h',
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3B5BDB),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class _Avatar extends StatelessWidget {
  final String initials;
  final double size;

  const _Avatar({required this.initials, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFEEF2FF),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: size * 0.35,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF3B5BDB),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final _TimesheetStatus status;
  final double? hours;
  final String? shortfall;

  const _StatusChip({required this.status, this.hours, this.shortfall});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;

    switch (status) {
      case _TimesheetStatus.approved:
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF059669);
        label = hours != null ? 'Approved\n${hours!.toInt()}h' : 'Approved';
        break;
      case _TimesheetStatus.rejected:
        bg = const Color(0xFFFFE4E6);
        fg = const Color(0xFFEF4444);
        label = hours != null ? 'Rejected\n${shortfall ?? '${hours!.toInt()}h'}' : 'Rejected';
        break;
      case _TimesheetStatus.pending:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        label = hours != null ? 'Pending\n${hours!.toInt()}h' : 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1.4,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}