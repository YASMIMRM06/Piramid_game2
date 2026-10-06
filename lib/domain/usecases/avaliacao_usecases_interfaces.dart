import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';

abstract interface class IRegistrarAvaliacaoUseCase
    implements IUseCase<AvaliacaoResult, AvaliarParams> {}

abstract interface class IAlterarAvaliacaoUseCase
    implements IUseCase<AvaliacaoResult, AvaliarParams> {}

/// Consulta a avaliação do usuário autenticado para uma pessoa (null se não houver).
abstract interface class IConsultarAvaliacaoUseCase
    implements IUseCase<AvaliacaoOptionalResult, PessoaIdParams> {}

/// Busca todas as avaliações feitas pelo usuário autenticado.
abstract interface class ICarregarAvaliacoesUseCase
    implements IUseCase<ListAvaliacaoResult, NoParams> {}

abstract interface class IVerificarAutoavaliacaoUseCase
    implements IUseCase<BoolResult, PessoaIdParams> {}
