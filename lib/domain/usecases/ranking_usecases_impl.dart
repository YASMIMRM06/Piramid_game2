import '../../core/failure/failure.dart';
import '../../core/messages/app_messages.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/auth_repository_interface.dart';
import '../../data/repositories/avaliacao_repository_interface.dart';
import '../../data/repositories/pessoa_repository_interface.dart';
import 'ranking_calculator.dart';
import 'ranking_usecases_interfaces.dart';

/// Ranking pessoal: considera exclusivamente as avaliações do usuário autenticado.
final class GetRankingPessoalUseCaseImpl implements IGetRankingPessoalUseCase {
  final IPessoaRepository _pessoas;
  final IAvaliacaoRepository _avaliacoes;
  final IAuthRepository _auth;
  GetRankingPessoalUseCaseImpl({
    required IPessoaRepository pessoaRepository,
    required IAvaliacaoRepository avaliacaoRepository,
    required IAuthRepository authRepository,
  })  : _pessoas = pessoaRepository,
        _avaliacoes = avaliacaoRepository,
        _auth = authRepository;

  @override
  Future<RankingResult> call(NoParams params) async {
    final user = _auth.currentUser;
    if (user == null) {
      return Error(AuthFailure(AppMessages.error.notAuthenticated));
    }

    final pessoas = await _pessoas.getAll();
    if (pessoas.isFailure) return Error(pessoas.failureValueOrNull!);
    final avaliacoes = await _avaliacoes.getByAvaliador(user.uid);
    if (avaliacoes.isFailure) return Error(avaliacoes.failureValueOrNull!);

    return Success(RankingCalculator.pessoal(
      pessoas.successValueOrNull!,
      avaliacoes.successValueOrNull!,
    ));
  }
}

/// Ranking global: média das avaliações de todos os usuários.
final class GetRankingGlobalUseCaseImpl implements IGetRankingGlobalUseCase {
  final IPessoaRepository _pessoas;
  final IAvaliacaoRepository _avaliacoes;
  GetRankingGlobalUseCaseImpl({
    required IPessoaRepository pessoaRepository,
    required IAvaliacaoRepository avaliacaoRepository,
  })  : _pessoas = pessoaRepository,
        _avaliacoes = avaliacaoRepository;

  @override
  Future<RankingResult> call(NoParams params) async {
    final pessoas = await _pessoas.getAll();
    if (pessoas.isFailure) return Error(pessoas.failureValueOrNull!);
    final avaliacoes = await _avaliacoes.getAll();
    if (avaliacoes.isFailure) return Error(avaliacoes.failureValueOrNull!);

    return Success(RankingCalculator.global(
      pessoas.successValueOrNull!,
      avaliacoes.successValueOrNull!,
    ));
  }
}
