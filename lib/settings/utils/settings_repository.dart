import 'package:shared_preferences/shared_preferences.dart';

import 'settings_enum.dart';

class SettingsRepository {
  SettingsRepository._();

  static late SharedPreferences _preferences;
  static SharedPreferences get getPreferences => _preferences;

  static init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future<bool> resetToDefault() {
    return _preferences.clear();
  }

  static Future<bool> setDefaultBpm(int value) {
    return _preferences.setInt(SettingsEnum.defaultBpm.key, value);
  }

  static int get defaultBpm {
    return _preferences.getInt(SettingsEnum.defaultBpm.key) ?? 150;
  }
}
