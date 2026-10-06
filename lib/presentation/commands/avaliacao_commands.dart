import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart' as r;
import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/avaliacao_facade_usecases_interface.dart';
import '../../domain/models/avaliacao_entity.dart';

final class AvaliarPessoaCommand
    extends ParameterizedCommand<Avaliacao, Failure, AvaliarParams> {
  final IAvaliacaoFacadeUseCases _facade;
  AvaliarPessoaCommand(this._facade);

  @override
  Future<AvaliacaoResult> execute() async {
    final p = parameter;
    if (p == null) return r.Error(InputFailure());
    return _facade.avaliar(p);
  }
}

final class AlterarAvaliacaoCommand
    extends ParameterizedCommand<Avaliacao, Failure, AvaliarParams> {
  final IAvaliacaoFacadeUseCases _facade;
  AlterarAvaliacaoCommand(this._facade);

  @override
  Future<AvaliacaoResult> execute() async {
    final p = parameter;
    if (p == null) return r.Error(InputFailure());
    return _facade.alterarAvaliacao(p);
  }
}

final class ConsultarAvaliacaoCommand
    extends ParameterizedCommand<Avaliacao?, Failure, PessoaIdParams> {
  final IAvaliacaoFacadeUseCases _facade;
  ConsultarAvaliacaoCommand(this._facade);

  @override
  Future<AvaliacaoOptionalResult> execute() async {
    final p = parameter;
    if (p == null) return r.Error(InputFailure());
    return _facade.consultarAvaliacao(p);
  }
}

final class CarregarAvaliacoesCommand
    extends ParameterizedCommand<List<Avaliacao>, Failure, NoParams> {
  final IAvaliacaoFacadeUseCases _facade;
  CarregarAvaliacoesCommand(this._facade);

  @override
  Future<ListAvaliacaoResult> execute() => _facade.carregarAvaliacoes(());
}

final class VerificarAutoavaliacaoCommand
    extends ParameterizedCommand<bool, Failure, PessoaIdParams> {
  final IAvaliacaoFacadeUseCases _facade;
  VerificarAutoavaliacaoCommand(this._facade);

  @override
  Future<BoolResult> execute() async {
    final p = parameter;
    if (p == null) return r.Error(InputFailure());
    return _facade.verificarAutoavaliacao(p);
  }
}
