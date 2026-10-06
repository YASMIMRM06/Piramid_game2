import '../../core/typedefs/types_defs.dart';
import '../../domain/models/pessoa_entity.dart';

abstract interface class IPessoaRepository {
  Future<ListPessoaResult> getAll();
  Future<PessoaResult> getById(String id);
  Future<PessoaResult> save(Pessoa pessoa); // cria ou altera
  Future<VoidResult> delete(String id);
  Future<VoidResult> vincularUsuario(String pessoaId, String uid);
}
