
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReglagesProvider extends ChangeNotifier {
  static const String _cleTheme = 'theme';

  final SharedPreferences _prefs;
  late ThemeMode _themeMode;

  ReglagesProvider(this._prefs) {
    _themeMode = _lireTheme();
  }

  ThemeMode get themeMode => _themeMode;

  // Lire le thème sauvegardé
  ThemeMode _lireTheme() {
    final nom = _prefs.getString(_cleTheme);

    return ThemeMode.values.firstWhere(
          (mode) => mode.name == nom,
      orElse: () => ThemeMode.system,
    );
  }

  // Modifier et enregistrer le thème
  Future<void> changerTheme(ThemeMode mode) async {
    _themeMode = mode;

    await _prefs.setString(_cleTheme, mode.name);

    notifyListeners();
  }
}
