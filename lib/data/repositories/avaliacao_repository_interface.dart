import '../../core/typedefs/types_defs.dart';
import '../../domain/models/avaliacao_entity.dart';

abstract interface class IAvaliacaoRepository {
  Future<AvaliacaoResult> save(Avaliacao avaliacao); // cria ou altera
  Future<AvaliacaoOptionalResult> getById(String id);
  Future<ListAvaliacaoResult> getByAvaliador(String uid);
  Future<ListAvaliacaoResult> getAll();
}
