import 'package:demo4/core/config/app_environment.dart';
import 'package:logger/logger.dart';

class FirebaseService {
  FirebaseService(this._environment, this._logger);

  final AppEnvironment _environment;
  final Logger _logger;

  Future<void> init() async {
    if (!_environment.enableFirebase) return;

    _logger.w(
      'Firebase is enabled in the environment, but Firebase packages are '
      'disabled in pubspec.yaml. Skipping initialization.',
    );
  }
}
