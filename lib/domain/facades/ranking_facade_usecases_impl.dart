import '../../core/typedefs/types_defs.dart';
import '../usecases/ranking_usecases_interfaces.dart';
import 'ranking_facade_usecases_interface.dart';

final class RankingFacadeUseCasesImpl implements IRankingFacadeUseCases {
  final IGetRankingPessoalUseCase _pessoal;
  final IGetRankingGlobalUseCase _global;

  RankingFacadeUseCasesImpl({
    required IGetRankingPessoalUseCase getRankingPessoalUseCase,
    required IGetRankingGlobalUseCase getRankingGlobalUseCase,
  })  : _pessoal = getRankingPessoalUseCase,
        _global = getRankingGlobalUseCase;

  @override
  Future<RankingResult> gerarRankingPessoal(NoParams params) => _pessoal(params);

  @override
  Future<RankingResult> gerarRankingGlobal(NoParams params) => _global(params);
}
