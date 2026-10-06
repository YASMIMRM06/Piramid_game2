import 'package:signals_flutter/signals_flutter.dart';

import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/avaliacao_facade_usecases_interface.dart';
import '../../domain/models/avaliacao_entity.dart';
import '../commands/avaliacao_commands.dart';

/// ViewModel das avaliações do usuário autenticado.
class AvaliacaoViewModel {
  final IAvaliacaoFacadeUseCases _facade;

  AvaliacaoViewModel(this._facade);

  // ── Estado reativo ─────────────────────────────────────────────
  final minhasAvaliacoes = signal<List<Avaliacao>>([]);
  final message = signal<String?>(null);

  // ── Commands ───────────────────────────────────────────────────
  late final avaliarCommand = AvaliarPessoaCommand(_facade);
  late final alterarCommand = AlterarAvaliacaoCommand(_facade);
  late final consultarCommand = ConsultarAvaliacaoCommand(_facade);
  late final carregarCommand = CarregarAvaliacoesCommand(_facade);
  late final verificarAutoCommand = VerificarAutoavaliacaoCommand(_facade);

  // ── Ações chamadas pela UI ─────────────────────────────────────

  /// Registra (primeira vez) ou altera (já existe) a avaliação de uma pessoa.
  Future<AvaliacaoResult> salvarAvaliacao({
    required String pessoaId,
    required Map<Criterio, int> notas,
    required bool jaAvaliada,
  }) async {
    message.value = null;
    final params = (pessoaId: pessoaId, notas: notas);
    final result = jaAvaliada
        ? await alterarCommand.executeWith(params)
        : await avaliarCommand.executeWith(params);
    result.fold<void>(
      onSuccess: (avaliacao) {
        minhasAvaliacoes.value = [
          ...minhasAvaliacoes.value.where((a) => a.id != avaliacao.id),
          avaliacao,
        ];
      },
      onFailure: (falha) {
        message.value = falha.msg;
      },
    );
    return result;
  }

  /// Avaliação do usuário para [pessoaId] (null se ainda não avaliou).
  Future<Avaliacao?> consultar(String pessoaId) async {
    final result = await consultarCommand.executeWith((id: pessoaId));
    return result.fold<Avaliacao?>(
      onSuccess: (avaliacao) => avaliacao,
      onFailure: (falha) {
        message.value = falha.msg;
        return null;
      },
    );
  }

  Future<void> carregarAvaliacoes() async {
    final result = await carregarCommand.executeWith(());
    result.fold<void>(
      onSuccess: (lista) {
        minhasAvaliacoes.value = lista;
      },
      onFailure: (falha) {
        message.value = falha.msg;
      },
    );
  }

  /// true se [pessoaId] é o próprio usuário autenticado (autoavaliação).
  Future<bool> verificarAutoavaliacao(String pessoaId) async {
    final result = await verificarAutoCommand.executeWith((id: pessoaId));
    return result.fold<bool>(
      onSuccess: (ehEle) => ehEle,
      onFailure: (falha) {
        message.value = falha.msg;
        return false;
      },
    );
  }
}
