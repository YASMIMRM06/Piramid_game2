import '../../core/typedefs/types_defs.dart';

abstract interface class IPessoaFacadeUseCases {
  Future<PessoaResult> cadastrar(PessoaParams params);
  Future<PessoaResult> buscar(PessoaIdParams params);
  Future<ListPessoaResult> listar(NoParams params);
  Future<PessoaResult> alterar(PessoaParams params);
  Future<VoidResult> remover(PessoaIdParams params);
  Future<PessoaResult> vincular(PessoaIdParams params);
}
