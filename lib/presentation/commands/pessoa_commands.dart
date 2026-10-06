import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart' as r;
import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/pessoa_facade_usecases_interface.dart';
import '../../domain/models/pessoa_entity.dart';

final class ListarPessoasCommand
    extends ParameterizedCommand<List<Pessoa>, Failure, NoParams> {
  final IPessoaFacadeUseCases _facade;
  ListarPessoasCommand(this._facade);

  @override
  Future<ListPessoaResult> execute() => _facade.listar(());
}

final class CadastrarPessoaCommand
    extends ParameterizedCommand<Pessoa, Failure, PessoaParams> {
  final IPessoaFacadeUseCases _facade;
  CadastrarPessoaCommand(this._facade);

  @override
  Future<PessoaResult> execute() async {
    final p = parameter;
    if (p == null) return r.Error(InputFailure());
    return _facade.cadastrar(p);
  }
}

final class AlterarPessoaCommand
    extends ParameterizedCommand<Pessoa, Failure, PessoaParams> {
  final IPessoaFacadeUseCases _facade;
  AlterarPessoaCommand(this._facade);

  @override
  Future<PessoaResult> execute() async {
    final p = parameter;
    if (p == null) return r.Error(InputFailure());
    return _facade.alterar(p);
  }
}

final class RemoverPessoaCommand
    extends ParameterizedCommand<void, Failure, PessoaIdParams> {
  final IPessoaFacadeUseCases _facade;
  RemoverPessoaCommand(this._facade);

  @override
  Future<VoidResult> execute() async {
    final p = parameter;
    if (p == null || p.id.isEmpty) return r.Error(InputFailure());
    return _facade.remover(p);
  }
}

final class VincularPessoaCommand
    extends ParameterizedCommand<Pessoa, Failure, PessoaIdParams> {
  final IPessoaFacadeUseCases _facade;
  VincularPessoaCommand(this._facade);

  @override
  Future<PessoaResult> execute() async {
    final p = parameter;
    if (p == null || p.id.isEmpty) return r.Error(InputFailure());
    return _facade.vincular(p);
  }
}
