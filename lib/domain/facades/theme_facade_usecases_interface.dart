import '../../core/typedefs/types_defs.dart';
import '../../data/services/theme_local_storage_service.dart';
import '../usecases/theme_usecases.dart';

/// Facade que agrupa os use cases de tema, assim como
/// IStudentFacadeUseCases agrupa os use cases de aluno.
///
/// A ViewModel (ThemeController) passa a depender apenas desta facade,
/// sem conhecer os use cases individuais.
abstract interface class IThemeFacadeUseCases {
  Future<ThemeResult> getTheme(NoParams params);
  Future<ThemeResult> saveTheme(ThemeModeParam params);
}
