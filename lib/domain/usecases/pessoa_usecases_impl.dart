import 'package:uuid/uuid.dart';

import '../../core/failure/failure.dart';
import '../../core/messages/app_messages.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/auth_repository_interface.dart';
import '../../data/repositories/pessoa_repository_interface.dart';
import '../models/pessoa_entity.dart';
import 'pessoa_usecases_interfaces.dart';

/// Validações de negócio do cadastro de pessoa (retorna a mensagem de erro).
String? _validarPessoa(Pessoa p) {
  if (p.nome.trim().isEmpty) return 'Nome é obrigatório.';
  if (p.turmaAno < Pessoa.turmaMin || p.turmaAno > Pessoa.turmaMax) {
    return 'Turma/ano deve estar entre ${Pessoa.turmaMin} e ${Pessoa.turmaMax}.';
  }
  return null;
}

/// Um usuário só pode estar vinculado a UMA pessoa.
Future<Failure?> _garantirVinculoUnico(
  IPessoaRepository repository,
  String uid, {
  String? ignorarPessoaId,
}) async {
  final todas = await repository.getAll();
  if (todas.isFailure) return todas.failureValueOrNull;
  final jaVinculada = todas.successValueOrNull!
      .any((p) => p.usuarioUid == uid && p.id != ignorarPessoaId);
  if (jaVinculada) {
    return InputFailure('Sua conta já está vinculada a outra pessoa.');
  }
  return null;
}

final class GetAllPessoasUseCaseImpl implements IGetAllPessoasUseCase {
  final IPessoaRepository _repository;
  GetAllPessoasUseCaseImpl({required IPessoaRepository repository})
      : _repository = repository;

  @override
  Future<ListPessoaResult> call(NoParams params) => _repository.getAll();
}

final class GetPessoaByIdUseCaseImpl implements IGetPessoaByIdUseCase {
  final IPessoaRepository _repository;
  GetPessoaByIdUseCaseImpl({required IPessoaRepository repository})
      : _repository = repository;

  @override
  Future<PessoaResult> call(PessoaIdParams params) =>
      _repository.getById(params.id);
}

final class SavePessoaUseCaseImpl implements ISavePessoaUseCase {
  final IPessoaRepository _repository;
  final IAuthRepository _auth;
  SavePessoaUseCaseImpl({
    required IPessoaRepository repository,
    required IAuthRepository authRepository,
  })  : _repository = repository,
        _auth = authRepository;

  @override
  Future<PessoaResult> call(PessoaParams params) async {
    final user = _auth.currentUser;
    if (user == null) {
      return Error(AuthFailure(AppMessages.error.notAuthenticated));
    }
    final erro = _validarPessoa(params.pessoa);
    if (erro != null) return Error(InputFailure(erro));

    // "Esta pessoa sou eu": vincula ao usuário autenticado.
    final vincular = params.pessoa.usuarioUid != null;
    if (vincular) {
      final falha = await _garantirVinculoUnico(_repository, user.uid);
      if (falha != null) return Error(falha);
    }

    final pessoa = params.pessoa.copyWith(
      id: const Uuid().v4(),
      nome: params.pessoa.nome.trim(),
      apelido: params.pessoa.apelido.trim(),
      criadoPor: user.uid,
      usuarioUid: vincular ? user.uid : null,
      removerVinculo: !vincular,
    );
    return _repository.save(pessoa);
  }
}

final class UpdatePessoaUseCaseImpl implements IUpdatePessoaUseCase {
  final IPessoaRepository _repository;
  final IAuthRepository _auth;
  UpdatePessoaUseCaseImpl({
    required IPessoaRepository repository,
    required IAuthRepository authRepository,
  })  : _repository = repository,
        _auth = authRepository;

  @override
  Future<PessoaResult> call(PessoaParams params) async {
    final user = _auth.currentUser;
    if (user == null) {
      return Error(AuthFailure(AppMessages.error.notAuthenticated));
    }
    final erro = _validarPessoa(params.pessoa);
    if (erro != null) return Error(InputFailure(erro));

    final atual = await _repository.getById(params.pessoa.id);
    if (atual.isFailure) return Error(atual.failureValueOrNull!);
    final existente = atual.successValueOrNull!;

    if (existente.criadoPor != user.uid) {
      return Error(AuthFailure(
          'Somente quem cadastrou a pessoa pode alterar seus dados.'));
    }

    // Se a pessoa está vinculada à conta de OUTRO usuário, o vínculo é mantido.
    final vinculadaAOutro =
        existente.usuarioUid != null && existente.usuarioUid != user.uid;
    final String? novoVinculo;
    if (vinculadaAOutro) {
      novoVinculo = existente.usuarioUid;
    } else if (params.pessoa.usuarioUid != null) {
      final falha = await _garantirVinculoUnico(_repository, user.uid,
          ignorarPessoaId: existente.id);
      if (falha != null) return Error(falha);
      novoVinculo = user.uid;
    } else {
      novoVinculo = null;
    }

    final pessoa = params.pessoa.copyWith(
      nome: params.pessoa.nome.trim(),
      apelido: params.pessoa.apelido.trim(),
      criadoPor: existente.criadoPor,
      usuarioUid: novoVinculo,
      removerVinculo: novoVinculo == null,
    );
    return _repository.save(pessoa);
  }
}

final class DeletePessoaUseCaseImpl implements IDeletePessoaUseCase {
  final IPessoaRepository _repository;
  final IAuthRepository _auth;
  DeletePessoaUseCaseImpl({
    required IPessoaRepository repository,
    required IAuthRepository authRepository,
  })  : _repository = repository,
        _auth = authRepository;

  @override
  Future<VoidResult> call(PessoaIdParams params) async {
    final user = _auth.currentUser;
    if (user == null) {
      return Error(AuthFailure(AppMessages.error.notAuthenticated));
    }
    final atual = await _repository.getById(params.id);
    if (atual.isFailure) return Error(atual.failureValueOrNull!);

    if (atual.successValueOrNull!.criadoPor != user.uid) {
      return Error(AuthFailure(
          'Somente quem cadastrou a pessoa pode removê-la.'));
    }
    return _repository.delete(params.id);
  }
}

/// "Esta pessoa sou eu": vincula a conta autenticada a uma pessoa existente.
final class VincularPessoaUseCaseImpl implements IVincularPessoaUseCase {
  final IPessoaRepository _repository;
  final IAuthRepository _auth;
  VincularPessoaUseCaseImpl({
    required IPessoaRepository repository,
    required IAuthRepository authRepository,
  })  : _repository = repository,
        _auth = authRepository;

  @override
  Future<PessoaResult> call(PessoaIdParams params) async {
    final user = _auth.currentUser;
    if (user == null) {
      return Error(AuthFailure(AppMessages.error.notAuthenticated));
    }
    final atual = await _repository.getById(params.id);
    if (atual.isFailure) return Error(atual.failureValueOrNull!);
    final pessoa = atual.successValueOrNull!;

    if (pessoa.usuarioUid != null) {
      return Error(InputFailure('Esta pessoa já está vinculada a uma conta.'));
    }
    final falha = await _garantirVinculoUnico(_repository, user.uid);
    if (falha != null) return Error(falha);

    final salvo = await _repository.vincularUsuario(pessoa.id, user.uid);
    if (salvo.isFailure) return Error(salvo.failureValueOrNull!);
    return Success(pessoa.copyWith(usuarioUid: user.uid));
  }
}
