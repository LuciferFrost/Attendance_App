/// App route paths used throughout the application with GoRouter.
///
/// These constants define all the named routes and paths used in the app.
/// Use these constants instead of hardcoding route strings.
abstract class AppRoutes {
  /// Login screen route - entry point for the application
  static const String login = '/login';

  /// Dashboard/home screen route after authentication
  static const String dashboard = '/dashboard';

  /// Check-in screen route - for recording attendance
  static const String checkIn = '/check-in';

  /// Check-in success screen route
  static const String checkInSuccess = '/check-in-success';

  /// Work reason selection screen
  static const String workReason = '/work-reason';

  /// Attendance tracking screen
  static const String attendance = '/attendance';

  /// Check-in history screen
  static const String checkInHistory = '/check-in-history';

  /// Employee profile screen
  static const String profile = '/profile';

  /// Notifications screen
  static const String notifications = '/notifications';

  /// Meetings screen
  static const String meetings = '/meetings';

  /// Approvals screen
  static const String approvals = '/approvals';

  /// Settings screen
  static const String settings = '/settings';

  /// Geofencing/location screen
  static const String geofencing = '/geofencing';

  /// Shift management screen
  static const String shifts = '/shifts';

  /// Reports screen
  static const String reports = '/reports';

  /// Team/employees screen
  static const String team = '/team';

  /// Not found/error screen
  static const String notFound = '/404';
}