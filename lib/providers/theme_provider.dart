import 'package:flutter/material.dart';

/// Holds the app's current [ThemeMode] and lets any screen toggle between
/// Light and Dark mode without losing any other app state, since this
/// provider lives above MaterialApp in the widget tree.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool useDark) {
    _themeMode = useDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
