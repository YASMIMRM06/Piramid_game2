import 'package:go_router/go_router.dart';

import '../../core/di/dependency_injection.dart';
import '../../domain/models/avaliacao_entity.dart';
import '../../domain/models/pessoa_entity.dart';
import '../../presentation/controllers/auth_viewmodel.dart';
import '../../presentation/controllers/avaliacao_viewmodel.dart';
import '../../presentation/controllers/pessoa_viewmodel.dart';
import '../../presentation/controllers/ranking_viewmodel.dart';
import '../../presentation/views/about/about_view.dart';
import '../../presentation/views/auth/login_view.dart';
import '../../presentation/views/avaliacao/avaliacao_view.dart';
import '../../presentation/views/home/home_view.dart';
import '../../presentation/views/pessoa/pessoa_detail_view.dart';
import '../../presentation/views/pessoa/pessoa_form_view.dart';
import '../../presentation/views/ranking/ranking_view.dart';
import '../../presentation/views/splash/splash_view.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const rankingPessoal = '/ranking/pessoal';
  static const rankingGlobal = '/ranking/global';
  static const about = '/about';
  static const pessoaForm = '/pessoa/form';
  static const pessoaDetail = '/pessoa/detail';
  static const avaliar = '/pessoa/avaliar';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  // Proteção de rotas: só usuários autenticados acessam as funcionalidades
  // principais. Splash e Login são as únicas rotas públicas.
  redirect: (context, state) {
    final auth = injector.get<AuthViewModel>();
    final local = state.matchedLocation;

    // Ainda não verificou a sessão salva → passa pela Splash primeiro.
    if (!auth.sessionChecked.value) {
      return local == AppRoutes.splash ? null : AppRoutes.splash;
    }

    final logado = auth.isAuthenticated.value;
    final rotaPublica = local == AppRoutes.splash || local == AppRoutes.login;

    if (!logado && !rotaPublica) return AppRoutes.login;
    if (logado && local == AppRoutes.login) return AppRoutes.home;
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => LoginView(
        viewModel: injector.get<AuthViewModel>(),
      ),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => HomeView(
        pessoaViewModel: injector.get<PessoaViewModel>(),
        rankingViewModel: injector.get<RankingViewModel>(),
        authViewModel: injector.get<AuthViewModel>(),
      ),
    ),
    GoRoute(
      path: AppRoutes.rankingPessoal,
      builder: (context, state) => RankingView(
        viewModel: injector.get<RankingViewModel>(),
        tipo: RankingType.pessoal,
      ),
    ),
    GoRoute(
      path: AppRoutes.rankingGlobal,
      builder: (context, state) => RankingView(
        viewModel: injector.get<RankingViewModel>(),
        tipo: RankingType.global,
      ),
    ),
    GoRoute(
      path: AppRoutes.about,
      builder: (context, state) => const AboutView(),
    ),
    GoRoute(
      path: AppRoutes.pessoaForm,
      builder: (context, state) {
        final pessoa = state.extra as Pessoa?;
        return PessoaFormView(
          viewModel: injector.get<PessoaViewModel>(),
          authViewModel: injector.get<AuthViewModel>(),
          pessoaToEdit: pessoa,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.pessoaDetail,
      builder: (context, state) {
        final pessoa = state.extra as Pessoa;
        return PessoaDetailView(
          pessoaViewModel: injector.get<PessoaViewModel>(),
          avaliacaoViewModel: injector.get<AvaliacaoViewModel>(),
          rankingViewModel: injector.get<RankingViewModel>(),
          authViewModel: injector.get<AuthViewModel>(),
          pessoa: pessoa,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.avaliar,
      builder: (context, state) {
        final args = state.extra as ({Pessoa pessoa, Avaliacao? avaliacao});
        return AvaliacaoView(
          viewModel: injector.get<AvaliacaoViewModel>(),
          pessoa: args.pessoa,
          avaliacaoExistente: args.avaliacao,
        );
      },
    ),
  ],
);
