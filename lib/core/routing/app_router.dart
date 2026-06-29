import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/homescreen.dart';
import '../../features/attendance/presentation/screens/checkin_screen.dart';
import '../../features/attendance/presentation/screens/checkin_success_screen.dart';
import '../../features/attendance/presentation/screens/checkout_success_screen.dart';
import '../../features/attendance/presentation/screens/workReason_screen.dart';
import 'package:demo4/features/attendance/presentation/screens/check_out_exception_screen.dart';
import '../../features/attendance/presentation/screens/shortLeave_apply_screen.dart';
import '../../features/attendance/presentation/screens/short_leave_pending_screen.dart';
import '../../features/attendance_dashboard/presentation/screens/attendance_list_screen.dart';
import '../../features/attendance_dashboard/presentation/screens/attendance_detail_screen.dart';
import '../../features/attendance_dashboard/presentation/screens/attendance_correction_screen.dart';
import '../../features/attendance_dashboard/domain/entities/attendance_record.dart';
import '../../features/leaves/presentation/screens/leave_dashboard_screen.dart';
import '../../features/leaves/presentation/screens/leave_apply_screen.dart';
import '../../features/dashboard/presentation/screens/early_checkin_screen.dart';
import '../../features/manager/presentation/screens/team_attendance_screen.dart';
import '../../features/manager/presentation/screens/approvals_screen.dart';
import '../../features/timesheet/presentation/screens/timesheet_screen.dart';
import '../../features/timesheet/presentation/screens/timesheet_day_screen.dart';
import '../../features/timesheet/presentation/screens/timesheet_entry_screen.dart';
import '../../features/timesheet/domain/entities/timesheet_models.dart';

import '../../features/attendance/presentation/screens/holiday_warning_screen.dart';


import 'package:demo4/features/profile/data/models/user_profile_model.dart';
import 'package:demo4/features/profile/presentation/screens/profile_screen.dart';
import 'package:demo4/features/profile/presentation/screens/edit_profile_screen.dart';

import '../../features/manager/presentation/screens/attendance_exception_screen.dart';
import '../../features/manager/presentation/screens/regularization_screen.dart';
import '../../features/manager/presentation/screens/leave_approvals_screen.dart';

import 'app_routes.dart';

/// Provider for the GoRouter instance
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const HomeScreen(),

      ),
      GoRoute(
        path: AppRoutes.checkIn,
        name: 'check-in-full',
        builder: (context, state) {
          final isCheckOut = state.extra is bool ? state.extra as bool : false;
          return CheckInScreen(isCheckOut: isCheckOut);
        },
      ),
      GoRoute(
        path: AppRoutes.checkInSuccess,
        name: 'check-in-success',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return CheckInSuccessScreen(
            attendanceStatus: args['attendanceStatus'] ?? '',
            geofenceStatus: args['geofenceStatus'] ?? '',
            checkInTime: args['checkInTime'] ?? '',
            workMode: args['workMode'] ?? '',
            location: args['location'] ?? '',
            shiftType: args['shiftType'] ?? '',
            isCheckOut: args['isCheckOut'] ?? false,
            approvalFound: args['approvalFound'] ?? false,
            isWithinGeofence: args['isWithinGeofence'] ?? false,
            isWfh: args['isWfh'] ?? false,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.checkOutSuccess,
        name: 'check-out-success',
        builder: (context, state) => const CheckOutScreen(),
      ),
      GoRoute(
        path: AppRoutes.workReason,
        name: 'work-reason',
        builder: (context, state) => const WorkReasonScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkOutException,
        name: 'check-out-exception',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          return CheckOutExceptionScreen(
            latitude: extras['latitude'] as double,
            longitude: extras['longitude'] as double,
            distanceInMeters: extras['distanceInMeters'] as double,
            officeLocation: extras['officeLocation'] as String,
            officeLatitude: extras['officeLatitude'] as double,
            officeLongitude: extras['officeLongitude'] as double,
            attemptedAt: extras['attemptedAt'] as DateTime,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.shortLeaveApply,
        name: 'short-leave-apply',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return ShortLeaveApplyScreen(
            checkInTime: args['checkInTime'] as String,
            checkOutTime: args['checkOutTime'] as String,
            totalHours: args['totalHours'] as Duration,
            shortfall: args['shortfall'] as Duration,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.shortLeavePending,
        name: 'short-leave-pending',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return ShortLeavePendingScreen(
            checkInTime: args['checkInTime'] as String,
            checkOutTime: args['checkOutTime'] as String,
            totalHours: args['totalHours'] as Duration,
            shortfall: args['shortfall'] as Duration,
            managerName: args['managerName'] as String,
            requestSentTime: args['requestSentTime'] as String,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.attendance,
        name: 'attendance',
        builder: (context, state) => const AttendanceListScreen(),
      ),
      GoRoute(
        path: AppRoutes.attendanceDetail,
        name: 'attendance-detail',
        builder: (context, state) {
          final record = state.extra as AttendanceRecord;
          return AttendanceDetailScreen(record: record);
        },
      ),
      GoRoute(
        path: AppRoutes.attendanceCorrection,
        name: 'attendance-correction',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is AttendanceRecord) {
            return AttendanceCorrectionScreen(record: extra);
          }
          final args = extra as Map<String, dynamic>;
          return AttendanceCorrectionScreen(
            record: args['record'] as AttendanceRecord,
            openedFromList: args['openedFromList'] as bool? ?? false,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.leave,
        name: 'leave',
        builder: (context, state) => const LeaveDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.leaveApply,
        name: 'leave-apply',
        builder: (context, state) => const LeaveApplyScreen(),
      ),

      // ─── Timesheet ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.timesheet,
        name: 'timesheet',
        builder: (context, state) => const TimesheetScreen(),
      ),
      GoRoute(
        path: AppRoutes.timesheetDay,
        name: 'timesheet-day',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return TimesheetDayScreen(
            date: args['date'] as DateTime,
            isCurrentDay: args['isCurrentDay'] as bool? ?? false,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.timesheetAddEntry,
        name: 'timesheet-add-entry',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return TimesheetEntryScreen(
            date: args['date'] as DateTime,
            day: args['day'] as TimesheetDay,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.timesheetEditEntry,
        name: 'timesheet-edit-entry',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return TimesheetEntryScreen(
            date: args['date'] as DateTime,
            day: args['day'] as TimesheetDay,
            existingEntry: args['entry'] as TimesheetEntry,
          );
        },
      ),

      // Add after the check-in route entry:
      GoRoute(
        path: AppRoutes.holidayWarning,
        name: 'holiday-warning',
        builder: (context, state) => const HolidayWarningScreen(),
      ),
      GoRoute(
        path: AppRoutes.earlyCheckIn,
        builder: (context, state) => EarlyCheckInScreen(
          shiftStartTime: state.extra as String,
        ),
      ),

      GoRoute(
        path: AppRoutes.profile,
        name: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),

        routes: [
          GoRoute(
            path: 'edit',                         // resolves to /profile/edit
            name: AppRoutes.editProfile,
            builder: (context, state) {
              // Pass the current profile as an extra object
              final profile = state.extra as UserProfileModel;
              return EditProfileScreen(profile: profile);
            },
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.teamAttendance,
        name: 'team-attendance',
        builder: (context, state) => const TeamAttendanceScreen(),
      ),

      GoRoute(
        path: AppRoutes.approvals,
        builder: (context, state) => const ApprovalsScreen(),
        routes: [
          GoRoute(
            path: 'attendance-exception',
            name: 'attendance-exception',
            builder: (context, state) => const AttendanceExceptionScreen(),
          ),
          GoRoute(
            path: 'regularization',
            name: 'regularization',
            builder: (context, state) => const RegularizationScreen(),
          ),
          GoRoute(
            path: 'leave-approvals',
            name: 'leave-approvals',
            builder: (context, state) => const LeaveApprovalsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text('Page not found: ${state.uri}'),
        ),
      );
    },
  );
});