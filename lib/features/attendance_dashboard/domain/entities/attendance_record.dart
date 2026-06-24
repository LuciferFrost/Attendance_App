/// Attendance status for a single day's record.
enum AttendanceStatus {
  present,
  late,
  absent,
  halfDay,
}

extension AttendanceStatusX on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'PRESENT';
      case AttendanceStatus.late:
        return 'LATE';
      case AttendanceStatus.absent:
        return 'ABSENT';
      case AttendanceStatus.halfDay:
        return 'HALF DAY';
    }
  }
}

/// Approval state for a regularization / correction request raised
/// against a particular day's attendance.
enum RegularizationState {
  /// No correction has been requested for this day.
  none,

  /// A correction request is awaiting manager approval.
  pendingApproval,

  /// A correction request was approved by the manager.
  approved,

  /// A correction request was rejected by the manager.
  rejected,
}

/// A single field captured as part of an attendance day, shown in the
/// "Field details" section of the Attendance Details screen (e.g. for
/// work-from-home / client-visit justifications).
class AttendanceFieldDetail {
  final String label;
  final String value;

  const AttendanceFieldDetail({required this.label, required this.value});
}

/// Represents one day's attendance entry for the signed-in employee.
///
/// This mirrors the data shown in the Figma "Attendance" flow:
/// attendance list -> attendance detail -> correction request -> submit.
class AttendanceRecord {
  final String id;
  final String employeeId;
  final DateTime date;
  final AttendanceStatus status;
  final RegularizationState regularizationState;

  /// Free-form tag shown alongside the absence reason, e.g. "Unplanned
  /// Absence recorded". Null when there is nothing to flag.
  final String? statusNote;

  final DateTime? checkInTime;
  final DateTime? checkOutTime;

  /// Pre-formatted total worked duration, e.g. "9h 14m". Kept as a string
  /// since half-day/absent rows render a literal "-" instead of a duration.
  final String? totalHoursLabel;

  final String workMode; // e.g. "In-office", "Work from home"
  final String shiftLabel; // e.g. "Morning Shift (10:00 AM – 06:30 PM)"
  final String locationLabel; // e.g. "Sector 62, Noida, Uttar Pradesh"
  final bool insideGeofence;
  final List<AttendanceFieldDetail> fieldDetails;

  const AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.status,
    this.regularizationState = RegularizationState.none,
    this.statusNote,
    this.checkInTime,
    this.checkOutTime,
    this.totalHoursLabel,
    this.workMode = 'In-office',
    this.shiftLabel = 'Morning Shift (10:00 AM – 06:30 PM)',
    this.locationLabel = 'Sector 62, Noida, Uttar Pradesh',
    this.insideGeofence = true,
    this.fieldDetails = const [],
  });

  /// Whether this day can be regularized (i.e. has a missing punch or an
  /// absence that the employee may want to correct).
  bool get canRegularize =>
      status == AttendanceStatus.absent ||
      status == AttendanceStatus.late ||
      checkInTime == null ||
      checkOutTime == null;
}
