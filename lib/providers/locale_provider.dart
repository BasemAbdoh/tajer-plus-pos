import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localePrefKey = 'app_locale';
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  LocaleProvider() {
    loadLocale();
  }

  Future<void> loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString(_localePrefKey) ?? 'ar';
      _locale = Locale(savedLocale);
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading locale preference: $e");
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localePrefKey, locale.languageCode);
    } catch (e) {
      debugPrint("Error saving locale preference: $e");
    }
  }

  Future<void> toggleLocale() async {
    final newLocale = _locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    await setLocale(newLocale);
  }
}
