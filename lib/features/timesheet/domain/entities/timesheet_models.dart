/// Status of a daily timesheet submission.
enum TimesheetDayStatus {
  draft,
  submitted,
  approved,
  rejected,
}

extension TimesheetDayStatusX on TimesheetDayStatus {
  String get label {
    switch (this) {
      case TimesheetDayStatus.draft:
        return 'DRAFT';
      case TimesheetDayStatus.submitted:
        return 'SUBMITTED';
      case TimesheetDayStatus.approved:
        return 'Approved';
      case TimesheetDayStatus.rejected:
        return 'Rejected';
    }
  }
}

/// A single time-log entry within a day's timesheet.
class TimesheetEntry {
  final String id;
  final String projectName;

  /// Null when [projectName] is one of the known projects (not "Other").
  final String? customProjectName;

  final String activity;
  final String subActivity;
  final Duration hours;

  /// Optional free-text remarks.
  final String? remarks;

  final bool billable;

  const TimesheetEntry({
    required this.id,
    required this.projectName,
    this.customProjectName,
    required this.activity,
    required this.subActivity,
    required this.hours,
    this.remarks,
    this.billable = true,
  });

  TimesheetEntry copyWith({
    String? projectName,
    String? customProjectName,
    String? activity,
    String? subActivity,
    Duration? hours,
    String? remarks,
    bool? billable,
  }) {
    return TimesheetEntry(
      id: id,
      projectName: projectName ?? this.projectName,
      customProjectName: customProjectName ?? this.customProjectName,
      activity: activity ?? this.activity,
      subActivity: subActivity ?? this.subActivity,
      hours: hours ?? this.hours,
      remarks: remarks ?? this.remarks,
      billable: billable ?? this.billable,
    );
  }
}

/// Aggregated record for a single calendar day.
class TimesheetDay {
  final DateTime date;
  final List<TimesheetEntry> entries;
  final TimesheetDayStatus status;

  /// Required hours for the day (typically 9h).
  final Duration requiredHours;

  const TimesheetDay({
    required this.date,
    required this.entries,
    this.status = TimesheetDayStatus.draft,
    this.requiredHours = const Duration(hours: 9),
  });

  Duration get totalLogged =>
      entries.fold(Duration.zero, (sum, e) => sum + e.hours);

  Duration get shortfall {
    final diff = requiredHours - totalLogged;
    return diff.isNegative ? Duration.zero : diff;
  }

  bool get hasShortfall => totalLogged < requiredHours;
}

/// Weekly summary shown on the Timesheet list screen.
class TimesheetWeek {
  final DateTime weekStart; // Monday
  final DateTime weekEnd;   // Sunday
  final List<TimesheetDay> days;

  /// Total hours required for the week.
  final Duration weeklyRequired;

  const TimesheetWeek({
    required this.weekStart,
    required this.weekEnd,
    required this.days,
    this.weeklyRequired = const Duration(hours: 45),
  });

  Duration get totalLogged =>
      days.fold(Duration.zero, (sum, d) => sum + d.totalLogged);

  Duration get remaining {
    final diff = weeklyRequired - totalLogged;
    return diff.isNegative ? Duration.zero : diff;
  }

  int get completionPercent =>
      ((totalLogged.inMinutes / weeklyRequired.inMinutes) * 100)
          .clamp(0, 100)
          .round();
}