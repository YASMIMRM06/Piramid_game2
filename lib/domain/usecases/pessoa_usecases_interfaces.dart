import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';

abstract interface class IGetAllPessoasUseCase
    implements IUseCase<ListPessoaResult, NoParams> {}

abstract interface class IGetPessoaByIdUseCase
    implements IUseCase<PessoaResult, PessoaIdParams> {}

abstract interface class ISavePessoaUseCase
    implements IUseCase<PessoaResult, PessoaParams> {}

abstract interface class IUpdatePessoaUseCase
    implements IUseCase<PessoaResult, PessoaParams> {}

abstract interface class IDeletePessoaUseCase
    implements IUseCase<VoidResult, PessoaIdParams> {}

abstract interface class IVincularPessoaUseCase
    implements IUseCase<PessoaResult, PessoaIdParams> {}
