/// Snapshot of the employee's current leave balance for a given period.
class LeaveBalance {
  final int casualLeave;
  final int shortLeave;
  final int lateMark;
  final DateTime periodStart;
  final DateTime periodEnd;

  const LeaveBalance({
    required this.casualLeave,
    required this.shortLeave,
    required this.lateMark,
    required this.periodStart,
    required this.periodEnd,
  });
}