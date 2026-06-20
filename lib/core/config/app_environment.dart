import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppFlavor { dev, staging, production }

class AppEnvironment {
  const AppEnvironment({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.enableFirebase,
  });

  final AppFlavor flavor;
  final String appName;
  final String apiBaseUrl;
  final bool enableFirebase;

  static AppEnvironment current = const AppEnvironment(
    flavor: AppFlavor.dev,
    appName: 'CraftEdge HRMS',
    apiBaseUrl: 'https://dev-api.craftedge.local',
    enableFirebase: false,
  );

  static Future<AppEnvironment> load(AppFlavor flavor) async {
    final fileName = switch (flavor) {
      AppFlavor.dev => '.env.dev',
      AppFlavor.staging => '.env.staging',
      AppFlavor.production => '.env.production',
    };

    await dotenv.load(fileName: 'assets/env/$fileName');
    current = AppEnvironment(
      flavor: flavor,
      appName: dotenv.get('APP_NAME', fallback: 'CraftEdge HRMS'),
      apiBaseUrl: dotenv.get('API_BASE_URL'),
      enableFirebase: dotenv.getBool('ENABLE_FIREBASE', fallback: false),
    );
    return current;
  }
}
