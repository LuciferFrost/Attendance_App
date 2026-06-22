class CheckOutSummary {
  final DateTime checkInTime;
  final DateTime checkOutTime;
  final Duration totalWorked;
  final String location;
  final bool isWithinGeofence;
  final double timesheetLoggedHours;
  final double timesheetRequiredHours;

  CheckOutSummary({
    required this.checkInTime,
    required this.checkOutTime,
    required this.totalWorked,
    required this.location,
    required this.isWithinGeofence,
    required this.timesheetLoggedHours,
    required this.timesheetRequiredHours,
  });

  double get timesheetRemainingHours =>
      (timesheetRequiredHours - timesheetLoggedHours).clamp(0, double.infinity);
}
