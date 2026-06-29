import 'package:demo4/core/di/service_locator.dart';
import 'package:demo4/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:demo4/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => sl(),
);

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) {
  return ref.read(dashboardRepositoryProvider).fetchSummary();
});

class DashboardState {
  final String displayName;
  final String currentDate;
  final String initials;
  final String employeeCode;
  final bool isManager;
  final String shiftType;
  final int attendedDays;
  final int leavesLeft;
  final int totalLeaves;
  final bool isCheckedIn;
  final String shiftPeriod;
  final String workLocation;
  final String shiftStartTime;
  final String shiftEndTime;
  final double progressPercentage;
  final double hoursWorked;
  final String timeRemaining;

  DashboardState({
    required this.displayName,
    required this.currentDate,
    required this.initials,
    required this.isManager,
    required this.employeeCode,
    required this.shiftType,
    required this.attendedDays,
    required this.leavesLeft,
    required this.totalLeaves,
    required this.isCheckedIn,
    required this.shiftPeriod,
    required this.workLocation,
    required this.shiftStartTime,
    required this.shiftEndTime,
    required this.progressPercentage,
    required this.hoursWorked,
    required this.timeRemaining,
  });

  DashboardState copyWith({
    String? displayName,
    String? currentDate,
    String? initials,
    String? employeeCode,
    String? shiftType,
    bool? isManager,
    int? attendedDays,
    int? leavesLeft,
    int? totalLeaves,
    bool? isCheckedIn,
    String? shiftPeriod,
    String? workLocation,
    String? shiftStartTime,
    String? shiftEndTime,
    double? progressPercentage,
    double? hoursWorked,
    String? timeRemaining,
  }) {
    return DashboardState(
      displayName: displayName ?? this.displayName,
      currentDate: currentDate ?? this.currentDate,
      initials: initials ?? this.initials,
      employeeCode: employeeCode ?? this.employeeCode,
      shiftType: shiftType ?? this.shiftType,
      attendedDays: attendedDays ?? this.attendedDays,
      leavesLeft: leavesLeft ?? this.leavesLeft,
      totalLeaves: totalLeaves ?? this.totalLeaves,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      isManager: isManager ?? this.isManager,
      shiftPeriod: shiftPeriod ?? this.shiftPeriod,
      workLocation: workLocation ?? this.workLocation,
      shiftStartTime: shiftStartTime ?? this.shiftStartTime,
      shiftEndTime: shiftEndTime ?? this.shiftEndTime,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      hoursWorked: hoursWorked ?? this.hoursWorked,
      timeRemaining: timeRemaining ?? this.timeRemaining,
    );
  }
}

class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    return DashboardState(
          displayName: 'Admin',
          currentDate: 'Wed, 12 Jun 2024',
          initials: 'AD',
          employeeCode: 'EMP001',
          shiftType: 'Full-time',
          attendedDays: 20,
          leavesLeft: 5,
          totalLeaves: 25,
          isCheckedIn: false,
          isManager: true, // dummy — flip to false to test non-manager view
          shiftPeriod: 'Morning Shift',
          workLocation: 'In-Office',
          shiftStartTime: '09:00 AM',
          shiftEndTime: '06:00 PM',
          progressPercentage: 65.0,
          hoursWorked: 5.2,
          timeRemaining: '2h 48m',
        );
  }

  void initializeUserData() {
    // Mock initialization
  }

  void setCheckedIn(bool value) {
    state = state.copyWith(isCheckedIn: value);
  }
}

final dashboardStateProvider =
    NotifierProvider<DashboardNotifier, DashboardState>(() {
  return DashboardNotifier();
});
