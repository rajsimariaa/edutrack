import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeModeKey = 'theme_mode';
const _kFontSizeKey = 'font_size';
const _kHighContrastKey = 'high_contrast';
const _kReduceAnimationsKey = 'reduce_animations';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  double _fontSize = 1.0;
  bool _highContrast = false;
  bool _reduceAnimations = false;

  ThemeMode get themeMode => _themeMode;
  double get fontSize => _fontSize;
  bool get highContrast => _highContrast;
  bool get reduceAnimations => _reduceAnimations;

  ThemeNotifier() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_kThemeModeKey) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    _fontSize = prefs.getDouble(_kFontSizeKey) ?? 1.0;
    _highContrast = prefs.getBool(_kHighContrastKey) ?? false;
    _reduceAnimations = prefs.getBool(_kReduceAnimationsKey) ?? false;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeModeKey, mode.index);
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFontSizeKey, size);
  }

  Future<void> setHighContrast(bool value) async {
    _highContrast = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHighContrastKey, value);
  }

  Future<void> setReduceAnimations(bool value) async {
    _reduceAnimations = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kReduceAnimationsKey, value);
  }
}

final themeProvider = ChangeNotifierProvider<ThemeNotifier>((ref) {
  return ThemeNotifier();
});
