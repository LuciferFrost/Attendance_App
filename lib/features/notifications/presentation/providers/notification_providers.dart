import 'package:demo4/features/notifications/data/models/app_notification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationsProvider = Provider<List<AppNotification>>((ref) {
  return [
    AppNotification(
      title: 'Leave requests pending',
      body: '14 leave requests are pending your approval.',
      createdAt: DateTime(2026, 5, 29, 11, 34),
    ),
    AppNotification(
      title: 'Payroll cycle',
      body: 'Payroll cycle due in 3 days. Review before processing.',
      createdAt: DateTime(2026, 5, 28, 9),
    ),
  ];
});
