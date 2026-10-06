import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../domain/facades/theme_facade_usecases_interface.dart';

/// ViewModel do tema.
///
/// Depende apenas da [IThemeFacadeUseCases], sem conhecer os use cases
/// individuais — mantendo a mesma cadeia arquitetural usada para os alunos:
/// services → repositories → use cases → facade → viewmodel (aqui) → UI.
class ThemeController {
  final IThemeFacadeUseCases _facade;

  ThemeController({required IThemeFacadeUseCases facade}) : _facade = facade;

  final themeMode = signal<ThemeMode>(ThemeMode.light);

  late final isLightMode = computed(() => themeMode.value == ThemeMode.light);

  /// Carrega a preferência salva ao iniciar o app.
  /// Chamado em main() antes do runApp().
  Future<void> loadTheme() async {
    // NoParams = () — passa a tuple vazia como valor
    final result = await _facade.getTheme(const ());
    result.fold(
      onSuccess: (mode) => themeMode.value = mode,
      onFailure: (_) => themeMode.value = ThemeMode.light,
    );
  }

  /// Alterna o tema e persiste a escolha.
  Future<void> toggleTheme() async {
    final next = themeMode.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    themeMode.value = next;
    await _facade.saveTheme((mode: next));
  }
}