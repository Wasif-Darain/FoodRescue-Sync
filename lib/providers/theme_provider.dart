import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight theme controller so the whole app can react to a
/// light/dark toggle from a single source of truth. The chosen mode
/// is persisted to SharedPreferences so it survives app restarts.
class ThemeProvider extends ChangeNotifier {
  static const _prefKey = 'themeMode';
  ThemeMode _mode = ThemeMode.light;
  bool _loaded = false;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_prefKey);
      if (stored == 'dark') {
        _mode = ThemeMode.dark;
      } else if (stored == 'light') {
        _mode = ThemeMode.light;
      }
      _loaded = true;
      notifyListeners();
    } catch (_) {
      _loaded = true;
    }
  }

  Future<void> toggle() async {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, _mode == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {}
  }
}