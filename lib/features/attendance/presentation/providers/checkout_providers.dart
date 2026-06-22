import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/check_out_summary.dart';

/// Provides the data shown on the Check Out screen.
///
/// Currently backed by static mock data matching the design mock. Swap the
/// body of this provider for a call into an AttendanceRepository once the
/// check-out data source is wired up — the screen itself won't need to
/// change since it only depends on [CheckOutSummary].
final checkOutSummaryProvider = Provider<CheckOutSummary>((ref) {
  final today = DateTime.now();

  return CheckOutSummary(
    checkInTime: DateTime(today.year, today.month, today.day, 9, 4),
    checkOutTime: DateTime(today.year, today.month, today.day, 18, 32),
    totalWorked: const Duration(hours: 9, minutes: 28),
    location: 'Craftedge office',
    isWithinGeofence: true,
    timesheetLoggedHours: 8.2,
    timesheetRequiredHours: 9.0,
  );
});