import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_enum.dart';

class SettingsRepository {
  SettingsRepository._();

  static late SharedPreferences _preferences;
  static SharedPreferences get getPreferences => _preferences;

  static late ValueNotifier<ThemeMode> _themeMode;

  static init() async {
    _preferences = await SharedPreferences.getInstance();

    _themeMode = ValueNotifier(
        ThemeMode.values[_preferences.getInt(SettingsEnum.themeMode.key) ?? 0]);
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

  static Future<bool> setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    return _preferences.setInt(SettingsEnum.themeMode.key, mode.index);
  }

  static ValueNotifier<ThemeMode> get themeMode {
    return _themeMode;
  }
}
