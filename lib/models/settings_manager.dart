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

  String get currentThemeName => _currentThemeName;
  Map<String, TextStyle> get currentTheme => _availableThemes[_currentThemeName]!;
  double get fontSize => _fontSize;
  String get lastConsoleOutput => _lastConsoleOutput;
  List<String> get availableThemeNames => _availableThemes.keys.toList();

  void setLastConsoleOutput(String output) {
    _lastConsoleOutput = output;
    // We don't need to notify listeners for this, as it's not directly displayed
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