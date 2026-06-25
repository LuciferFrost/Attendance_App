import '../../domain/entities/timesheet_models.dart';

/// Provides dummy timesheet data for development / UI work.
/// Replace with a real API-backed implementation later.
class TimesheetRepository {
  TimesheetRepository._();

  static final TimesheetRepository instance = TimesheetRepository._();

  // In-memory store keyed by date string "yyyy-MM-dd"
  final Map<String, TimesheetDay> _store = {};
  bool _seeded = false;

  /// Returns the current week's [TimesheetWeek].
  TimesheetWeek getCurrentWeek() {
    _seedIfNeeded();
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);
    final weekEnd = weekStart.add(const Duration(days: 6));

    final days = List.generate(7, (i) {
      final date = weekStart.add(Duration(days: i));
      return _store[_key(date)] ??
          TimesheetDay(date: date, entries: const []);
    });

    return TimesheetWeek(
      weekStart: weekStart,
      weekEnd: weekEnd,
      days: days,
    );
  }

  TimesheetDay getDay(DateTime date) {
    _seedIfNeeded();
    final d = DateTime(date.year, date.month, date.day);
    return _store[_key(d)] ?? TimesheetDay(date: d, entries: const []);
  }

  void saveEntry(DateTime date, TimesheetEntry entry) {
    final d = DateTime(date.year, date.month, date.day);
    final existing = getDay(d);
    final updated = [
      ...existing.entries.where((e) => e.id != entry.id),
      entry,
    ];
    _store[_key(d)] = TimesheetDay(
      date: d,
      entries: updated,
      status: existing.status == TimesheetDayStatus.approved
          ? existing.status
          : TimesheetDayStatus.draft,
      requiredHours: existing.requiredHours,
    );
  }

  void deleteEntry(DateTime date, String entryId) {
    final d = DateTime(date.year, date.month, date.day);
    final existing = getDay(d);
    final updated = existing.entries.where((e) => e.id != entryId).toList();
    _store[_key(d)] = TimesheetDay(
      date: d,
      entries: updated,
      status: existing.status,
      requiredHours: existing.requiredHours,
    );
  }

  void submitDay(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final existing = getDay(d);
    _store[_key(d)] = TimesheetDay(
      date: d,
      entries: existing.entries,
      status: TimesheetDayStatus.submitted,
      requiredHours: existing.requiredHours,
    );
  }

  void saveDraft(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final existing = getDay(d);
    _store[_key(d)] = TimesheetDay(
      date: d,
      entries: existing.entries,
      status: TimesheetDayStatus.draft,
      requiredHours: existing.requiredHours,
    );
  }

  // ─── helpers ────────────────────────────────────────────────────────────────

  static String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _seedIfNeeded() {
    if (_seeded) return;
    _seeded = true;

    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    // Monday — 9h, Approved
    _seedDay(
      monday,
      TimesheetDayStatus.approved,
      [
        _entry('e1', 'CraftEdge Mobile App', 'Development', 'Backend Integration',
            const Duration(hours: 4),
            remarks: 'API integration for attendance module.'),
        _entry('e2', 'Internal Operations', 'Meeting', 'Sprint Planning',
            const Duration(hours: 2),
            remarks: 'Q2 sprint planning.'),
        _entry('e3', 'CraftEdge Mobile App', 'Testing', 'QA Review',
            const Duration(hours: 3),
            remarks: 'Auth flow UI testing.'),
      ],
    );

    // Tuesday — 9.5h, Approved
    _seedDay(
      monday.add(const Duration(days: 1)),
      TimesheetDayStatus.approved,
      [
        _entry('e4', 'CraftEdge Mobile App', 'Development', 'UI Components',
            const Duration(hours: 5),
            remarks: 'Dashboard widgets implementation.'),
        _entry('e5', 'Internal Operations', 'Training', 'Flutter Deepdive',
            const Duration(hours: 4, minutes: 30),
            remarks: 'Riverpod advanced patterns.'),
      ],
    );

    // Wednesday — 10h, Approved
    _seedDay(
      monday.add(const Duration(days: 2)),
      TimesheetDayStatus.approved,
      [
        _entry('e6', 'CraftEdge Mobile App', 'Development', 'Backend Integration',
            const Duration(hours: 3),
            remarks: 'API integration for attendance module — check-in/out endpoints.'),
        _entry('e7', 'Internal Operations', 'Meeting', 'Sprint Planning',
            const Duration(hours: 1),
            remarks: 'Q2 sprint planning and backlog grooming.'),
        _entry('e8', 'CraftEdge Mobile App', 'Testing', 'QA Review',
            const Duration(hours: 3),
            remarks: 'UI testing for authentication flow and error handling validation.'),
        _entry('e9', 'Internal Operations', 'Documentation', 'API Docs',
            const Duration(hours: 3),
            remarks: 'Swagger spec update.'),
      ],
    );

    // Thursday (today context) — 3h, Draft (in-progress)
    _seedDay(
      monday.add(const Duration(days: 3)),
      TimesheetDayStatus.draft,
      [
        _entry('e10', 'CraftEdge Mobile App', 'Development', 'Timesheet Feature',
            const Duration(hours: 2),
            remarks: 'Building timesheet screens.'),
        _entry('e11', 'Internal Operations', 'Meeting', 'Daily Standup',
            const Duration(hours: 1),
            remarks: 'Daily sync.'),
      ],
    );
  }

  void _seedDay(
      DateTime date,
      TimesheetDayStatus status,
      List<TimesheetEntry> entries,
      ) {
    _store[_key(date)] = TimesheetDay(
      date: date,
      entries: entries,
      status: status,
    );
  }

  static TimesheetEntry _entry(
      String id,
      String project,
      String activity,
      String subActivity,
      Duration hours, {
        String? remarks,
      }) {
    return TimesheetEntry(
      id: id,
      projectName: project,
      activity: activity,
      subActivity: subActivity,
      hours: hours,
      remarks: remarks,
    );
  }
}

/// Known project options for the Add/Edit Entry dropdown.
const kTimesheetProjects = [
  'CraftEdge Mobile App',
  'Internal Operations',
  'CraftEdge Web Portal',
  'Other',
];