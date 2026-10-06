import '../../core/failure/failure.dart';
import '../../core/messages/app_messages.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/auth_repository_interface.dart';
import '../../data/repositories/avaliacao_repository_interface.dart';
import '../../data/repositories/pessoa_repository_interface.dart';
import '../models/avaliacao_entity.dart';
import 'avaliacao_usecases_interfaces.dart';

/// Valida e monta a [Avaliacao] (regras da seção 16 da especificação):
/// - exige usuário autenticado;
/// - exige os 15 critérios com notas entre 1 e 5;
/// - impede a autoavaliação;
/// - usa id determinístico (usuário + pessoa = uma avaliação);
/// - calcula a pontuação total automaticamente (Avaliacao.pontuacaoTotal).
Future<Result<Avaliacao, Failure>> _montarAvaliacao({
  required IAuthRepository auth,
  required IPessoaRepository pessoas,
  required AvaliarParams params,
}) async {
  final user = auth.currentUser;
  if (user == null) {
    return Error(AuthFailure(AppMessages.error.notAuthenticated));
  }
  if (params.pessoaId.isEmpty) {
    return Error(InputFailure('Pessoa inválida.'));
  }
  if (!Avaliacao.notasValidas(params.notas)) {
    return Error(InputFailure(
        'Avalie os 15 critérios com notas de ${Avaliacao.notaMin} a ${Avaliacao.notaMax}.'));
  }

  final pessoaResult = await pessoas.getById(params.pessoaId);
  if (pessoaResult.isFailure) return Error(pessoaResult.failureValueOrNull!);

  if (pessoaResult.successValueOrNull!.usuarioUid == user.uid) {
    return Error(InputFailure(AppMessages.error.selfEvaluation));
  }

  return Success(Avaliacao(
    id: Avaliacao.buildId(user.uid, params.pessoaId),
    avaliadorUid: user.uid,
    pessoaId: params.pessoaId,
    notas: Map<Criterio, int>.from(params.notas),
    dataAvaliacao: DateTime.now(),
  ));
}

final class RegistrarAvaliacaoUseCaseImpl implements IRegistrarAvaliacaoUseCase {
  final IAvaliacaoRepository _avaliacoes;
  final IPessoaRepository _pessoas;
  final IAuthRepository _auth;
  RegistrarAvaliacaoUseCaseImpl({
    required IAvaliacaoRepository avaliacaoRepository,
    required IPessoaRepository pessoaRepository,
    required IAuthRepository authRepository,
  })  : _avaliacoes = avaliacaoRepository,
        _pessoas = pessoaRepository,
        _auth = authRepository;

  @override
  Future<AvaliacaoResult> call(AvaliarParams params) async {
    final montada =
        await _montarAvaliacao(auth: _auth, pessoas: _pessoas, params: params);
    if (montada.isFailure) return Error(montada.failureValueOrNull!);
    final avaliacao = montada.successValueOrNull!;

    final existente = await _avaliacoes.getById(avaliacao.id);
    if (existente.isFailure) return Error(existente.failureValueOrNull!);
    if (existente.successValueOrNull != null) {
      return Error(InputFailure(
          'Você já avaliou esta pessoa. Altere a avaliação existente.'));
    }
    return _avaliacoes.save(avaliacao);
  }
}

final class AlterarAvaliacaoUseCaseImpl implements IAlterarAvaliacaoUseCase {
  final IAvaliacaoRepository _avaliacoes;
  final IPessoaRepository _pessoas;
  final IAuthRepository _auth;
  AlterarAvaliacaoUseCaseImpl({
    required IAvaliacaoRepository avaliacaoRepository,
    required IPessoaRepository pessoaRepository,
    required IAuthRepository authRepository,
  })  : _avaliacoes = avaliacaoRepository,
        _pessoas = pessoaRepository,
        _auth = authRepository;

  @override
  Future<AvaliacaoResult> call(AvaliarParams params) async {
    final montada =
        await _montarAvaliacao(auth: _auth, pessoas: _pessoas, params: params);
    if (montada.isFailure) return Error(montada.failureValueOrNull!);
    final avaliacao = montada.successValueOrNull!;

    final existente = await _avaliacoes.getById(avaliacao.id);
    if (existente.isFailure) return Error(existente.failureValueOrNull!);
    if (existente.successValueOrNull == null) {
      return Error(EmptyResultFailure(
          'Avaliação não encontrada. Registre uma nova avaliação.'));
    }
    return _avaliacoes.save(avaliacao);
  }
}

final class ConsultarAvaliacaoUseCaseImpl implements IConsultarAvaliacaoUseCase {
  final IAvaliacaoRepository _avaliacoes;
  final IAuthRepository _auth;
  ConsultarAvaliacaoUseCaseImpl({
    required IAvaliacaoRepository avaliacaoRepository,
    required IAuthRepository authRepository,
  })  : _avaliacoes = avaliacaoRepository,
        _auth = authRepository;

  @override
  Future<AvaliacaoOptionalResult> call(PessoaIdParams params) async {
    final user = _auth.currentUser;
    if (user == null) {
      return Error(AuthFailure(AppMessages.error.notAuthenticated));
    }
    return _avaliacoes.getById(Avaliacao.buildId(user.uid, params.id));
  }
}

final class CarregarAvaliacoesUseCaseImpl implements ICarregarAvaliacoesUseCase {
  final IAvaliacaoRepository _avaliacoes;
  final IAuthRepository _auth;
  CarregarAvaliacoesUseCaseImpl({
    required IAvaliacaoRepository avaliacaoRepository,
    required IAuthRepository authRepository,
  })  : _avaliacoes = avaliacaoRepository,
        _auth = authRepository;

  @override
  Future<ListAvaliacaoResult> call(NoParams params) async {
    final user = _auth.currentUser;
    if (user == null) {
      return Error(AuthFailure(AppMessages.error.notAuthenticated));
    }
    return _avaliacoes.getByAvaliador(user.uid);
  }
}

final class VerificarAutoavaliacaoUseCaseImpl
    implements IVerificarAutoavaliacaoUseCase {
  final IPessoaRepository _pessoas;
  final IAuthRepository _auth;
  VerificarAutoavaliacaoUseCaseImpl({
    required IPessoaRepository pessoaRepository,
    required IAuthRepository authRepository,
  })  : _pessoas = pessoaRepository,
        _auth = authRepository;

  @override
  Future<BoolResult> call(PessoaIdParams params) async {
    final user = _auth.currentUser;
    if (user == null) {
      return Error(AuthFailure(AppMessages.error.notAuthenticated));
    }
    final pessoa = await _pessoas.getById(params.id);
    if (pessoa.isFailure) return Error(pessoa.failureValueOrNull!);
    return Success(pessoa.successValueOrNull!.usuarioUid == user.uid);
  }
}
