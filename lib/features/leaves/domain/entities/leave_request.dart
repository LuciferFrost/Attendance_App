/// Type of leave an employee can apply for.
enum LeaveType {
  casual,
  sick,
  earned,
  halfDay,
  shortLeave,
}

extension LeaveTypeX on LeaveType {
  String get label {
    switch (this) {
      case LeaveType.casual:
        return 'Casual Leave';
      case LeaveType.sick:
        return 'Sick Leave';
      case LeaveType.earned:
        return 'Earned Leave';
      case LeaveType.halfDay:
        return 'Half-Day Leave';
      case LeaveType.shortLeave:
        return 'Short Leave';
    }
  }

  String get shortLabel {
    switch (this) {
      case LeaveType.casual:
        return 'Casual Leave';
      case LeaveType.sick:
        return 'Sick Leave';
      case LeaveType.earned:
        return 'Earned Leave';
      case LeaveType.halfDay:
        return 'Half-Day Leave';
      case LeaveType.shortLeave:
        return 'Short Leave';
    }
  }
}

/// Approval status of a leave request.
enum LeaveStatus {
  pending,
  approved,
  rejected,
}

extension LeaveStatusX on LeaveStatus {
  String get label {
    switch (this) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
    }
  }
}

/// A single leave request raised by an employee.
class LeaveRequest {
  final String id;
  final String employeeId;
  final LeaveType type;
  final LeaveStatus status;

  /// The primary date of leave.
  final DateTime leaveDate;

  /// Optional timing string, e.g. "5:00 PM" for a short/early-exit leave.
  final String? leaveTiming;

  /// Reason text provided by the employee.
  final String reason;

  /// Additional remarks / note for manager.
  final String? remarks;

  /// Short subtitle shown on the history card, e.g. "Approved by Priya Singh".
  final String subtitle;

  /// When this request was submitted.
  final DateTime submittedAt;

  const LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.status,
    required this.leaveDate,
    this.leaveTiming,
    required this.reason,
    this.remarks,
    required this.subtitle,
    required this.submittedAt,
  });
}