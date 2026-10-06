import 'package:flutter/material.dart';

import '../services/theme_local_storage_service.dart';

/// Camada de Repository do tema.
///
/// Assim como o IStudentRepository, esta interface intermedia o acesso
/// aos dados: os use cases dependem apenas do repository, e o repository
/// é quem conhece o service responsável por acessar o armazenamento local.
abstract interface class IThemeRepository {
  Future<ThemeResult> getTheme();
  Future<ThemeResult> saveTheme(ThemeMode mode);
}
