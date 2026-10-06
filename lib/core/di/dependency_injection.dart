import 'package:auto_injector/auto_injector.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/auth_repository_interface.dart';
import '../../data/repositories/avaliacao_repository_impl.dart';
import '../../data/repositories/avaliacao_repository_interface.dart';
import '../../data/repositories/pessoa_repository_impl.dart';
import '../../data/repositories/pessoa_repository_interface.dart';
import '../../data/repositories/theme_repository_impl.dart';
import '../../data/repositories/theme_repository_interface.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/google_auth_service.dart';
import '../../data/services/theme_local_storage_service.dart';
import '../../domain/facades/auth_facade_usecases_impl.dart';
import '../../domain/facades/auth_facade_usecases_interface.dart';
import '../../domain/facades/avaliacao_facade_usecases_impl.dart';
import '../../domain/facades/avaliacao_facade_usecases_interface.dart';
import '../../domain/facades/pessoa_facade_usecases_impl.dart';
import '../../domain/facades/pessoa_facade_usecases_interface.dart';
import '../../domain/facades/ranking_facade_usecases_impl.dart';
import '../../domain/facades/ranking_facade_usecases_interface.dart';
import '../../domain/facades/theme_facade_usecases_impl.dart';
import '../../domain/facades/theme_facade_usecases_interface.dart';
import '../../domain/usecases/auth_usecases_impl.dart';
import '../../domain/usecases/auth_usecases_interfaces.dart';
import '../../domain/usecases/avaliacao_usecases_impl.dart';
import '../../domain/usecases/avaliacao_usecases_interfaces.dart';
import '../../domain/usecases/pessoa_usecases_impl.dart';
import '../../domain/usecases/pessoa_usecases_interfaces.dart';
import '../../domain/usecases/ranking_usecases_impl.dart';
import '../../domain/usecases/ranking_usecases_interfaces.dart';
import '../../domain/usecases/theme_usecases.dart';
import '../../presentation/controllers/auth_viewmodel.dart';
import '../../presentation/controllers/avaliacao_viewmodel.dart';
import '../../presentation/controllers/pessoa_viewmodel.dart';
import '../../presentation/controllers/ranking_viewmodel.dart';
import '../theme/theme_controller.dart';

final injector = AutoInjector();

/// Deve ser chamado DEPOIS de Firebase.initializeApp().
void setupInjection() {
  // ── Theme (SharedPreferences) ──────────────────────────────────
  injector.addSingleton<IThemeLocalStorage>(ThemeSharedPreferencesService.new);
  injector.addSingleton<IThemeRepository>(ThemeRepositoryImpl.new);
  injector.addSingleton<IGetThemeUseCase>(GetThemeUseCaseImpl.new);
  injector.addSingleton<ISaveThemeUseCase>(SaveThemeUseCaseImpl.new);
  injector.addSingleton<IThemeFacadeUseCases>(ThemeFacadeUseCasesImpl.new);
  injector.addSingleton<ThemeController>(ThemeController.new);

  // ── Firebase (instâncias) ──────────────────────────────────────
  injector.addInstance<FirebaseAuth>(FirebaseAuth.instance);
  injector.addInstance<FirebaseFirestore>(FirebaseFirestore.instance);

  // ── Services ───────────────────────────────────────────────────
  injector.addSingleton<IAuthService>(AuthService.new);
  injector.addSingleton<IGoogleAuthService>(GoogleAuthService.new);
  injector.addSingleton<IFirestoreService>(FirestoreService.new);

  // ── Repositories ───────────────────────────────────────────────
  injector.addSingleton<IAuthRepository>(AuthRepositoryImpl.new);
  injector.addSingleton<IPessoaRepository>(PessoaRepositoryImpl.new);
  injector.addSingleton<IAvaliacaoRepository>(AvaliacaoRepositoryImpl.new);

  // ── Use cases: autenticação ────────────────────────────────────
  injector.addSingleton<IRegisterUserUseCase>(RegisterUserUseCaseImpl.new);
  injector.addSingleton<ILoginUseCase>(LoginUseCaseImpl.new);
  injector.addSingleton<ILoginGoogleUseCase>(LoginGoogleUseCaseImpl.new);
  injector.addSingleton<ICheckAuthenticatedUseCase>(
      CheckAuthenticatedUseCaseImpl.new);
  injector.addSingleton<ILogoutUseCase>(LogoutUseCaseImpl.new);

  // ── Use cases: pessoas ─────────────────────────────────────────
  injector.addSingleton<IGetAllPessoasUseCase>(GetAllPessoasUseCaseImpl.new);
  injector.addSingleton<IGetPessoaByIdUseCase>(GetPessoaByIdUseCaseImpl.new);
  injector.addSingleton<ISavePessoaUseCase>(SavePessoaUseCaseImpl.new);
  injector.addSingleton<IUpdatePessoaUseCase>(UpdatePessoaUseCaseImpl.new);
  injector.addSingleton<IDeletePessoaUseCase>(DeletePessoaUseCaseImpl.new);
  injector.addSingleton<IVincularPessoaUseCase>(VincularPessoaUseCaseImpl.new);

  // ── Use cases: avaliações ──────────────────────────────────────
  injector.addSingleton<IRegistrarAvaliacaoUseCase>(
      RegistrarAvaliacaoUseCaseImpl.new);
  injector.addSingleton<IAlterarAvaliacaoUseCase>(
      AlterarAvaliacaoUseCaseImpl.new);
  injector.addSingleton<IConsultarAvaliacaoUseCase>(
      ConsultarAvaliacaoUseCaseImpl.new);
  injector.addSingleton<ICarregarAvaliacoesUseCase>(
      CarregarAvaliacoesUseCaseImpl.new);
  injector.addSingleton<IVerificarAutoavaliacaoUseCase>(
      VerificarAutoavaliacaoUseCaseImpl.new);

  // ── Use cases: rankings ────────────────────────────────────────
  injector.addSingleton<IGetRankingPessoalUseCase>(
      GetRankingPessoalUseCaseImpl.new);
  injector.addSingleton<IGetRankingGlobalUseCase>(
      GetRankingGlobalUseCaseImpl.new);

  // ── Facades ────────────────────────────────────────────────────
  injector.addSingleton<IAuthFacadeUseCases>(AuthFacadeUseCasesImpl.new);
  injector.addSingleton<IPessoaFacadeUseCases>(PessoaFacadeUseCasesImpl.new);
  injector
      .addSingleton<IAvaliacaoFacadeUseCases>(AvaliacaoFacadeUseCasesImpl.new);
  injector.addSingleton<IRankingFacadeUseCases>(RankingFacadeUseCasesImpl.new);

  // ── ViewModels ─────────────────────────────────────────────────
  injector.addSingleton<AuthViewModel>(AuthViewModel.new);
  injector.addSingleton<PessoaViewModel>(PessoaViewModel.new);
  injector.addSingleton<AvaliacaoViewModel>(AvaliacaoViewModel.new);
  injector.addSingleton<RankingViewModel>(RankingViewModel.new);

  injector.commit();
}
