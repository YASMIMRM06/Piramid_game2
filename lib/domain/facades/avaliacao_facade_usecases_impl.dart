import '../../core/typedefs/types_defs.dart';
import '../usecases/avaliacao_usecases_interfaces.dart';
import 'avaliacao_facade_usecases_interface.dart';

final class AvaliacaoFacadeUseCasesImpl implements IAvaliacaoFacadeUseCases {
  final IRegistrarAvaliacaoUseCase _registrar;
  final IAlterarAvaliacaoUseCase _alterar;
  final IConsultarAvaliacaoUseCase _consultar;
  final ICarregarAvaliacoesUseCase _carregar;
  final IVerificarAutoavaliacaoUseCase _verificarAuto;

  AvaliacaoFacadeUseCasesImpl({
    required IRegistrarAvaliacaoUseCase registrarAvaliacaoUseCase,
    required IAlterarAvaliacaoUseCase alterarAvaliacaoUseCase,
    required IConsultarAvaliacaoUseCase consultarAvaliacaoUseCase,
    required ICarregarAvaliacoesUseCase carregarAvaliacoesUseCase,
    required IVerificarAutoavaliacaoUseCase verificarAutoavaliacaoUseCase,
  })  : _registrar = registrarAvaliacaoUseCase,
        _alterar = alterarAvaliacaoUseCase,
        _consultar = consultarAvaliacaoUseCase,
        _carregar = carregarAvaliacoesUseCase,
        _verificarAuto = verificarAutoavaliacaoUseCase;

  @override
  Future<AvaliacaoResult> avaliar(AvaliarParams params) => _registrar(params);

  @override
  Future<AvaliacaoResult> alterarAvaliacao(AvaliarParams params) =>
      _alterar(params);

  @override
  Future<AvaliacaoOptionalResult> consultarAvaliacao(PessoaIdParams params) =>
      _consultar(params);

  @override
  Future<ListAvaliacaoResult> carregarAvaliacoes(NoParams params) =>
      _carregar(params);

  @override
  Future<BoolResult> verificarAutoavaliacao(PessoaIdParams params) =>
      _verificarAuto(params);
}
