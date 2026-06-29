import 'package:demo4/core/routing/app_routes.dart';
import 'package:demo4/core/theme/app_spacing.dart';
import 'package:demo4/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.showAppBar = true,
    super.key,
  });

  final String title;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final destinations = [
      _Destination('Dashboard', Icons.dashboard_outlined, AppRoutes.dashboard),
      _Destination('Profile', Icons.person_outline, AppRoutes.profile),
      _Destination(
        'Notifications',
        Icons.notifications_none,
        AppRoutes.notifications,
      ),
      _Destination('Settings', Icons.settings_outlined, AppRoutes.settings),
    ];

    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(title)) : null,
      drawer: context.isDesktop || !showAppBar ? null : _NavigationDrawer(destinations),
      body: Row(
        children: [
          if (context.isDesktop)
            SizedBox(
              width: 224,
              child: _NavigationRail(destinations: destinations),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: padding,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationRail extends StatelessWidget {
  const _NavigationRail({required this.destinations});

  final List<_Destination> destinations;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF141B29),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CraftEdge', style: TextStyle(color: Colors.white)),
              const SizedBox(height: AppSpacing.lg),
              for (final item in destinations)
                ListTile(
                  textColor: Colors.white70,
                  iconColor: Colors.white70,
                  leading: Icon(item.icon),
                  title: Text(item.label),
                  onTap: () => context.go(item.route),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationDrawer extends StatelessWidget {
  const _NavigationDrawer(this.destinations);

  final List<_Destination> destinations;

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      children: [
        const DrawerHeader(child: Text('CraftEdge HRMS')),
        for (final item in destinations)
          ListTile(
            leading: Icon(item.icon),
            title: Text(item.label),
            onTap: () => context.go(item.route),
          ),
      ],
    );
  }
}

class _Destination {
  const _Destination(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}
