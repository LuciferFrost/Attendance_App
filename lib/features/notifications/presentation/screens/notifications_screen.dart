import 'package:demo4/core/widgets/app_shell.dart';
import 'package:demo4/features/notifications/presentation/providers/notification_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return AppShell(
      title: 'Notifications',
      child: Card(
        child: Column(
          children: [
            for (final notification in notifications)
              ListTile(
                leading: const Icon(Icons.notifications_none),
                title: Text(notification.title),
                subtitle: Text(notification.body),
                trailing: Text(
                  DateFormat.MMMd().format(notification.createdAt),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
