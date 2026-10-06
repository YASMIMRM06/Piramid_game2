import '../../core/typedefs/types_defs.dart';
import '../../domain/models/pessoa_entity.dart';
import '../services/firestore_service.dart';
import 'pessoa_repository_interface.dart';

final class PessoaRepositoryImpl implements IPessoaRepository {
  final IFirestoreService _firestore;

  PessoaRepositoryImpl({required IFirestoreService firestoreService})
      : _firestore = firestoreService;

  @override
  Future<ListPessoaResult> getAll() => _firestore.getAllPessoas();

  @override
  Future<PessoaResult> getById(String id) => _firestore.getPessoaById(id);

  @override
  Future<PessoaResult> save(Pessoa pessoa) => _firestore.savePessoa(pessoa);

  @override
  Future<VoidResult> delete(String id) => _firestore.deletePessoa(id);

  @override
  Future<VoidResult> vincularUsuario(String pessoaId, String uid) =>
      _firestore.vincularUsuario(pessoaId, uid);
}
