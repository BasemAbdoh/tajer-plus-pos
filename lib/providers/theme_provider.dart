import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themePrefKey = 'is_dark_mode';
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    loadTheme();
  }

  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themePrefKey) ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading theme preference: $e");
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePrefKey, isDark);
    } catch (e) {
      debugPrint("Error saving theme preference: $e");
    }
  }
}
