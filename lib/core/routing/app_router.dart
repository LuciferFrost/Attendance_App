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
// Import other screens as needed

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
        path: '/check-out-exception',
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
        builder: (context, state) => const ShortLeaveApplyScreen(),
      ),
      GoRoute(
        path: '/short-leave-pending',
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