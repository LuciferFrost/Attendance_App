import '../../domain/entities/leave_balance.dart';
import '../../domain/entities/leave_request.dart';

/// Dummy repository that supplies mock leave data.
/// Swap the implementations here once real API endpoints are available.
class DummyLeaveRepository {
  /// Returns the employee's current leave balance.
  LeaveBalance getLeaveBalance() {
    final now = DateTime.now();
    return LeaveBalance(
      casualLeave: 2,
      shortLeave: 3,
      lateMark: 2,
      periodStart: DateTime(now.year, now.month, 1),
      periodEnd: DateTime(now.year, now.month + 1, 0),
    );
  }

  /// Returns a list of past / pending leave requests, most-recent first.
  List<LeaveRequest> getLeaveHistory() {
    final now = DateTime.now();
    return [
      LeaveRequest(
        id: 'lv_001',
        employeeId: 'EMP-1042',
        type: LeaveType.casual,
        status: LeaveStatus.approved,
        leaveDate: DateTime(now.year, now.month - 1, 2),
        reason: 'Personal work',
        subtitle: 'Approved by Priya Singh',
        submittedAt: DateTime(now.year, now.month - 1, 1),
      ),
      LeaveRequest(
        id: 'lv_002',
        employeeId: 'EMP-1042',
        type: LeaveType.halfDay,
        status: LeaveStatus.rejected,
        leaveDate: DateTime(now.year, now.month - 1, 22),
        reason: 'Doctor appointment',
        subtitle: 'Approved · Worked 2nd half',
        submittedAt: DateTime(now.year, now.month - 1, 21),
      ),
      LeaveRequest(
        id: 'lv_003',
        employeeId: 'EMP-1042',
        type: LeaveType.shortLeave,
        status: LeaveStatus.pending,
        leaveDate: DateTime(now.year, now.month, now.day),
        leaveTiming: '5:00 PM',
        reason: 'Early exit',
        subtitle: 'Submitted today · Awaiting manager',
        submittedAt: DateTime.now(),
      ),
    ];
  }

  /// Submits a new leave request (returns the created request).
  Future<LeaveRequest> submitLeave({
    required LeaveType type,
    required DateTime leaveDate,
    String? leaveTiming,
    required String reason,
    String? remarks,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 900));

    return LeaveRequest(
      id: 'lv_new_${DateTime.now().millisecondsSinceEpoch}',
      employeeId: 'EMP-1042',
      type: type,
      status: LeaveStatus.pending,
      leaveDate: leaveDate,
      leaveTiming: leaveTiming,
      reason: reason,
      remarks: remarks,
      subtitle: 'Submitted today · Awaiting manager',
      submittedAt: DateTime.now(),
    );
  }
}