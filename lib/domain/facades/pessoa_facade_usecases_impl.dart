import '../../core/typedefs/types_defs.dart';
import '../usecases/pessoa_usecases_interfaces.dart';
import 'pessoa_facade_usecases_interface.dart';

final class PessoaFacadeUseCasesImpl implements IPessoaFacadeUseCases {
  final IGetAllPessoasUseCase _getAll;
  final IGetPessoaByIdUseCase _getById;
  final ISavePessoaUseCase _save;
  final IUpdatePessoaUseCase _update;
  final IDeletePessoaUseCase _delete;
  final IVincularPessoaUseCase _vincular;

  PessoaFacadeUseCasesImpl({
    required IGetAllPessoasUseCase getAllPessoasUseCase,
    required IGetPessoaByIdUseCase getPessoaByIdUseCase,
    required ISavePessoaUseCase savePessoaUseCase,
    required IUpdatePessoaUseCase updatePessoaUseCase,
    required IDeletePessoaUseCase deletePessoaUseCase,
    required IVincularPessoaUseCase vincularPessoaUseCase,
  })  : _getAll = getAllPessoasUseCase,
        _getById = getPessoaByIdUseCase,
        _save = savePessoaUseCase,
        _update = updatePessoaUseCase,
        _delete = deletePessoaUseCase,
        _vincular = vincularPessoaUseCase;

  @override
  Future<PessoaResult> cadastrar(PessoaParams params) => _save(params);

  @override
  Future<PessoaResult> buscar(PessoaIdParams params) => _getById(params);

  @override
  Future<ListPessoaResult> listar(NoParams params) => _getAll(params);

  @override
  Future<PessoaResult> alterar(PessoaParams params) => _update(params);

  @override
  Future<VoidResult> remover(PessoaIdParams params) => _delete(params);

  @override
  Future<PessoaResult> vincular(PessoaIdParams params) => _vincular(params);
}
