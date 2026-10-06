import '../../core/typedefs/types_defs.dart';
import '../../data/services/theme_local_storage_service.dart';
import '../usecases/theme_usecases.dart';
import 'theme_facade_usecases_interface.dart';

final class ThemeFacadeUseCasesImpl implements IThemeFacadeUseCases {
  final IGetThemeUseCase _getTheme;
  final ISaveThemeUseCase _saveTheme;

  ThemeFacadeUseCasesImpl({
    required IGetThemeUseCase getThemeUseCase,
    required ISaveThemeUseCase saveThemeUseCase,
  })  : _getTheme = getThemeUseCase,
        _saveTheme = saveThemeUseCase;

  @override
  Future<ThemeResult> getTheme(NoParams params) => _getTheme(params);

  @override
  Future<ThemeResult> saveTheme(ThemeModeParam params) =>
      _saveTheme(params);
}
