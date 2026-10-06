import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';

abstract interface class IGetRankingPessoalUseCase
    implements IUseCase<RankingResult, NoParams> {}

abstract interface class IGetRankingGlobalUseCase
    implements IUseCase<RankingResult, NoParams> {}
