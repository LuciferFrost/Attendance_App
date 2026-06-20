import 'package:demo4/core/services/analytics_service.dart';

class NotificationService {
  NotificationService(this._analytics);

  final AnalyticsService _analytics;

  Future<String?> registerDevice() async {
    await _analytics.logEvent('push_token_registration_skipped');
    return null;
  }
}
