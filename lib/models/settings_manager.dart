import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/solarized-dark.dart';
import 'package:flutter_highlight/themes/solarized-light.dart';

class SettingsManager extends ChangeNotifier {
  static final Map<String, Map<String, TextStyle>> _availableThemes = {
    'Monokai Sublime': monokaiSublimeTheme,
    'GitHub': githubTheme,
    'Solarized Dark': solarizedDarkTheme,
    'Solarized Light': solarizedLightTheme,
  };

  String _currentThemeName = 'Monokai Sublime';
  double _fontSize = 16.0;
  String _lastConsoleOutput = '';
  String _openRouterApiKey = '';
  String _openRouterModelName = 'alibaba/tongyi-deepresearch-30b-a3b:free'; // Default model

  String get currentThemeName => _currentThemeName;
  Map<String, TextStyle> get currentTheme => _availableThemes[_currentThemeName]!;
  double get fontSize => _fontSize;
  String get lastConsoleOutput => _lastConsoleOutput;
  List<String> get availableThemeNames => _availableThemes.keys.toList();
  String get openRouterApiKey => _openRouterApiKey;
  String get openRouterModelName => _openRouterModelName;

  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  bool _eyeProtection = false;
  bool get eyeProtection => _eyeProtection;

  void setLastConsoleOutput(String output) {
    _lastConsoleOutput = output;
    // We don't need to notify listeners for this, as it's not directly displayed
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleEyeProtection() {
    _eyeProtection = !_eyeProtection;
    notifyListeners();
  }

  void setOpenRouterApiKey(String apiKey) {
    _openRouterApiKey = apiKey;
    notifyListeners();
  }

  void setOpenRouterModelName(String modelName) {
    _openRouterModelName = modelName;
    notifyListeners();
  }

  void setTheme(String themeName) {
    if (_availableThemes.containsKey(themeName)) {
      _currentThemeName = themeName;
      notifyListeners();
    }
  }

  void increaseFontSize() {
    if (_fontSize < 30.0) {
      _fontSize += 2.0;
      notifyListeners();
    }
  }

  void decreaseFontSize() {
    if (_fontSize > 10.0) {
      _fontSize -= 2.0;
      notifyListeners();
    }
  }
}