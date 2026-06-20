import 'package:demo4/core/theme/app_spacing.dart';
import 'package:demo4/core/widgets/app_shell.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Profile',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Anjali Sharma',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text('EMP-1042 · HRBP · Level 4'),
              const SizedBox(height: AppSpacing.lg),
              const ListTile(
                title: Text('Department'),
                subtitle: Text('Human Resources'),
              ),
              const ListTile(
                title: Text('Manager'),
                subtitle: Text('Nisha Rao'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
