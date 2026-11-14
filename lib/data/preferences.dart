/// 贴记 PinNote · 偏好持久化（P2：主题 / 首启标记，shared_preferences）
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 偏好服务：main() 中先 [init]，之后同步读取
class PreferencesService {
  PreferencesService._();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ---------- 主题 ----------

  static ThemeMode get themeMode {
    if (_prefs == null) return ThemeMode.light;
    switch (_prefs!.getString('themeMode')) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  static void setThemeMode(ThemeMode mode) {
    if (_prefs == null) return;
    final name = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
    };
    _prefs!.setString('themeMode', name);
  }

  // ---------- 首启引导 ----------

  static bool get onboardingSeen =>
      _prefs?.getBool('onboardingSeen') ?? false;

  static void setOnboardingSeen() => _prefs?.setBool('onboardingSeen', true);
}
