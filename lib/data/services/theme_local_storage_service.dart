import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';

typedef ThemeResult = Result<ThemeMode, Failure>;

abstract interface class IThemeLocalStorage {
  Future<ThemeResult> getTheme();
  Future<ThemeResult> saveTheme(ThemeMode mode);
}

final class ThemeSharedPreferencesService implements IThemeLocalStorage {
  static const String _key = 'theme_mode';

  @override
  Future<ThemeResult> getTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key);
      if (saved == null) return const Success(ThemeMode.light);
      final mode = ThemeMode.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => ThemeMode.light,
      );
      return Success(mode);
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao carregar tema: $e'));
    }
  }

  @override
  Future<ThemeResult> saveTheme(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name);
      return Success(mode);
    } catch (e) {
      return Error(ApiLocalFailure('Erro ao salvar tema: $e'));
    }
  }
}