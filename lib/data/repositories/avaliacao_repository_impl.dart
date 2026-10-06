import '../../core/typedefs/types_defs.dart';
import '../../domain/models/avaliacao_entity.dart';
import '../services/firestore_service.dart';
import 'avaliacao_repository_interface.dart';

final class AvaliacaoRepositoryImpl implements IAvaliacaoRepository {
  final IFirestoreService _firestore;

  AvaliacaoRepositoryImpl({required IFirestoreService firestoreService})
      : _firestore = firestoreService;

  @override
  Future<AvaliacaoResult> save(Avaliacao avaliacao) =>
      _firestore.saveAvaliacao(avaliacao);

  @override
  Future<AvaliacaoOptionalResult> getById(String id) =>
      _firestore.getAvaliacaoById(id);

  @override
  Future<ListAvaliacaoResult> getByAvaliador(String uid) =>
      _firestore.getAvaliacoesByAvaliador(uid);

  @override
  Future<ListAvaliacaoResult> getAll() => _firestore.getAllAvaliacoes();
}
