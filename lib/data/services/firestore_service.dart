import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/avaliacao_entity.dart';
import '../../domain/models/avaliacao_mapper.dart';
import '../../domain/models/pessoa_entity.dart';
import '../../domain/models/pessoa_mapper.dart';
import '../../domain/models/usuario_entity.dart';
import '../../domain/models/usuario_mapper.dart';

/// Comunicação direta com o Cloud Firestore.
/// Coleções: `usuarios`, `pessoas` e `avaliacoes`.
abstract interface class IFirestoreService {
  // usuarios
  Future<VoidResult> saveUsuario(Usuario usuario);

  // pessoas
  Future<ListPessoaResult> getAllPessoas();
  Future<PessoaResult> getPessoaById(String id);
  Future<PessoaResult> savePessoa(Pessoa pessoa); // cria ou altera
  Future<VoidResult> deletePessoa(String id); // remove também as avaliações dela
  Future<VoidResult> vincularUsuario(String pessoaId, String uid);

  // avaliacoes
  Future<AvaliacaoResult> saveAvaliacao(Avaliacao avaliacao); // cria ou altera
  Future<AvaliacaoOptionalResult> getAvaliacaoById(String id);
  Future<ListAvaliacaoResult> getAvaliacoesByAvaliador(String uid);
  Future<ListAvaliacaoResult> getAllAvaliacoes();
}

final class FirestoreService implements IFirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({required FirebaseFirestore firestore}) : _db = firestore;

  CollectionReference<Map<String, dynamic>> get _usuarios =>
      _db.collection('usuarios');
  CollectionReference<Map<String, dynamic>> get _pessoas =>
      _db.collection('pessoas');
  CollectionReference<Map<String, dynamic>> get _avaliacoes =>
      _db.collection('avaliacoes');

  Failure _failure(String contexto, Object e) {
    if (e is FirebaseException && e.code == 'permission-denied') {
      return RemoteFailure(
          'Sem permissão para esta operação. Verifique as regras do Firestore.');
    }
    if (e is FirebaseException && e.code == 'unavailable') {
      return RemoteFailure('Sem conexão com o servidor.');
    }
    return RemoteFailure('$contexto: $e');
  }

  // ---------------------------------------------------------- usuarios
  @override
  Future<VoidResult> saveUsuario(Usuario usuario) async {
    try {
      await _usuarios
          .doc(usuario.uid)
          .set(UsuarioMapper.toMap(usuario), SetOptions(merge: true));
      return const Success(null);
    } catch (e) {
      return Error(_failure('Erro ao salvar usuário', e));
    }
  }

  // ----------------------------------------------------------- pessoas
  @override
  Future<ListPessoaResult> getAllPessoas() async {
    try {
      final snap = await _pessoas.get();
      final lista = snap.docs
          .map((d) => PessoaMapper.fromMap(d.id, d.data()))
          .toList()
        ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      return Success(lista);
    } catch (e) {
      return Error(_failure('Erro ao obter pessoas', e));
    }
  }

  @override
  Future<PessoaResult> getPessoaById(String id) async {
    try {
      final doc = await _pessoas.doc(id).get();
      final data = doc.data();
      if (!doc.exists || data == null) {
        return Error(EmptyResultFailure('Pessoa não encontrada.'));
      }
      return Success(PessoaMapper.fromMap(doc.id, data));
    } catch (e) {
      return Error(_failure('Erro ao buscar pessoa', e));
    }
  }

  @override
  Future<PessoaResult> savePessoa(Pessoa pessoa) async {
    try {
      await _pessoas.doc(pessoa.id).set(PessoaMapper.toMap(pessoa));
      return Success(pessoa);
    } catch (e) {
      return Error(_failure('Erro ao salvar pessoa', e));
    }
  }

  @override
  Future<VoidResult> deletePessoa(String id) async {
    try {
      // Remove a pessoa e, junto, todas as avaliações que ela recebeu,
      // para que os rankings não fiquem com dados órfãos.
      final avaliacoes = await _avaliacoes.where('pessoaId', isEqualTo: id).get();
      final batch = _db.batch();
      for (final doc in avaliacoes.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_pessoas.doc(id));
      await batch.commit();
      return const Success(null);
    } catch (e) {
      return Error(_failure('Erro ao remover pessoa', e));
    }
  }

  @override
  Future<VoidResult> vincularUsuario(String pessoaId, String uid) async {
    try {
      await _pessoas.doc(pessoaId).update({'usuarioUid': uid});
      return const Success(null);
    } catch (e) {
      return Error(_failure('Erro ao vincular usuário', e));
    }
  }

  // -------------------------------------------------------- avaliacoes
  @override
  Future<AvaliacaoResult> saveAvaliacao(Avaliacao avaliacao) async {
    try {
      await _avaliacoes.doc(avaliacao.id).set(AvaliacaoMapper.toMap(avaliacao));
      return Success(avaliacao);
    } catch (e) {
      return Error(_failure('Erro ao salvar avaliação', e));
    }
  }

  @override
  Future<AvaliacaoOptionalResult> getAvaliacaoById(String id) async {
    try {
      final doc = await _avaliacoes.doc(id).get();
      final data = doc.data();
      if (!doc.exists || data == null) return const Success(null);
      return Success(AvaliacaoMapper.fromMap(doc.id, data));
    } catch (e) {
      return Error(_failure('Erro ao buscar avaliação', e));
    }
  }

  @override
  Future<ListAvaliacaoResult> getAvaliacoesByAvaliador(String uid) async {
    try {
      final snap =
          await _avaliacoes.where('avaliadorUid', isEqualTo: uid).get();
      return Success(
        snap.docs.map((d) => AvaliacaoMapper.fromMap(d.id, d.data())).toList(),
      );
    } catch (e) {
      return Error(_failure('Erro ao obter avaliações', e));
    }
  }

  @override
  Future<ListAvaliacaoResult> getAllAvaliacoes() async {
    try {
      final snap = await _avaliacoes.get();
      return Success(
        snap.docs.map((d) => AvaliacaoMapper.fromMap(d.id, d.data())).toList(),
      );
    } catch (e) {
      return Error(_failure('Erro ao obter avaliações', e));
    }
  }
}
