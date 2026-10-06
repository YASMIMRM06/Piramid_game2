import 'package:flutter/material.dart';

import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/theme_repository_interface.dart';
import '../../data/services/theme_local_storage_service.dart';

// ThemeResult está definido em theme_local_storage_service.dart
typedef ThemeModeParam = ({ThemeMode mode});

// --- interfaces ---

abstract interface class IGetThemeUseCase
    implements IUseCase<ThemeResult, NoParams> {}

abstract interface class ISaveThemeUseCase
    implements IUseCase<ThemeResult, ThemeModeParam> {}

// --- implementações ---
//
// Agora dependem de IThemeRepository (e não mais do service diretamente),
// respeitando a arquitetura obrigatória:
// services → repositories → use cases → facade → viewmodel → UI

final class GetThemeUseCaseImpl implements IGetThemeUseCase {
  final IThemeRepository _repository;
  GetThemeUseCaseImpl({required IThemeRepository repository})
      : _repository = repository;

  @override
  Future<ThemeResult> call(NoParams params) => _repository.getTheme();
}

final class SaveThemeUseCaseImpl implements ISaveThemeUseCase {
  final IThemeRepository _repository;
  SaveThemeUseCaseImpl({required IThemeRepository repository})
      : _repository = repository;

  @override
  Future<ThemeResult> call(ThemeModeParam params) =>
      _repository.saveTheme(params.mode);
}