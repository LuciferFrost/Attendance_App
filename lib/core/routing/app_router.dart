import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/homescreen.dart';
import '../../features/attendance/presentation/screens/checkin_screen.dart';
import '../../features/attendance/presentation/screens/checkin_success_screen.dart';
import '../../features/attendance/presentation/screens/workReason_screen.dart';
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
        builder: (context, state) => const CheckInScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkInSuccess,
        name: 'check-in-success',
        builder: (context, state) {
          final args = state.extra as Map<String, String>;
          return CheckInSuccessScreen(
            attendanceStatus: args['attendanceStatus'] ?? '',
            geofenceStatus: args['geofenceStatus'] ?? '',
            checkInTime: args['checkInTime'] ?? '',
            workMode: args['workMode'] ?? '',
            location: args['location'] ?? '',
            shiftType: args['shiftType'] ?? '',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.workReason,
        name: 'work-reason',
        builder: (context, state) => const WorkReasonScreen(),
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