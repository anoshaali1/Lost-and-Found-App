import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  ThemeProvider() {
    loadTheme();
  }

  bool get isDark => _isDark;

  ThemeData get currentTheme => _isDark ? ThemeData.dark() : ThemeData.light();

  void toggleTheme() {
    _isDark = !_isDark;
    saveTheme();
    notifyListeners();
  }

  Future<void> saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDark', _isDark);
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDark') ?? false;
    notifyListeners();
  }
}
