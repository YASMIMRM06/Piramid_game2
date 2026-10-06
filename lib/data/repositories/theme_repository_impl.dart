import 'package:flutter/material.dart';

import '../services/theme_local_storage_service.dart';
import 'theme_repository_interface.dart';

/// Implementação do repository de tema.
///
/// Não conhece SharedPreferences diretamente — apenas delega para o
/// service ([IThemeLocalStorage]), respeitando a cadeia
/// services → repositories → use cases exigida pelo projeto.
final class ThemeRepositoryImpl implements IThemeRepository {
  final IThemeLocalStorage _localStorage;

  ThemeRepositoryImpl({required IThemeLocalStorage localStorage})
      : _localStorage = localStorage;

  @override
  Future<ThemeResult> getTheme() => _localStorage.getTheme();

  @override
  Future<ThemeResult> saveTheme(ThemeMode mode) =>
      _localStorage.saveTheme(mode);
}
