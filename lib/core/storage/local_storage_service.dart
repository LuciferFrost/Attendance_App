//import 'package:demo4/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService(this._preferences);

  final SharedPreferences _preferences;

  Future<void> init() async {
    // No initialization required
  }

  T? read<T>(String key) {
    final value = _preferences.get(key);
    return value as T?;
  }

  Future<void> write<T>(String key, T value) async {
    if (value is bool) {
      await _preferences.setBool(key, value);
    } else if (value is int) {
      await _preferences.setInt(key, value);
    } else if (value is double) {
      await _preferences.setDouble(key, value);
    } else if (value is String) {
      await _preferences.setString(key, value);
    } else if (value is List<String>) {
      await _preferences.setStringList(key, value);
    } else {
      throw UnsupportedError(
        'SharedPreferences does not support type ${value.runtimeType}',
      );
    }
  }

  bool getBool(String key, {bool fallback = false}) {
    return _preferences.getBool(key) ?? fallback;
  }

  Future<void> setBool(String key, bool value) {
    return _preferences.setBool(key, value);
  }
}