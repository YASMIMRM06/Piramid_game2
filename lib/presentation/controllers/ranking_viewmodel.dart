import 'package:signals_flutter/signals_flutter.dart';

import '../../domain/facades/ranking_facade_usecases_interface.dart';
import '../../domain/models/ranking_item.dart';
import '../commands/ranking_commands.dart';

/// ViewModel dos rankings pessoal e global.
class RankingViewModel {
  final IRankingFacadeUseCases _facade;

  RankingViewModel(this._facade);

  // ── Estado reativo ─────────────────────────────────────────────
  final personal = signal<List<RankingItem>>([]);
  final global = signal<List<RankingItem>>([]);
  final isLoading = signal<bool>(false);
  final message = signal<String?>(null);

  // ── Commands ───────────────────────────────────────────────────
  late final carregarRankingPessoalCommand =
      CarregarRankingPessoalCommand(_facade);
  late final carregarRankingGlobalCommand =
      CarregarRankingGlobalCommand(_facade);

  // ── Ações chamadas pela UI ─────────────────────────────────────
  Future<void> carregarPessoal() async {
    message.value = null;
    isLoading.value = true;
    final result = await carregarRankingPessoalCommand.executeWith(());
    result.fold<void>(
      onSuccess: (lista) {
        personal.value = lista;
      },
      onFailure: (falha) {
        message.value = falha.msg;
      },
    );
    isLoading.value = false;
  }

  Future<void> carregarGlobal() async {
    message.value = null;
    isLoading.value = true;
    final result = await carregarRankingGlobalCommand.executeWith(());
    result.fold<void>(
      onSuccess: (lista) {
        global.value = lista;
      },
      onFailure: (falha) {
        message.value = falha.msg;
      },
    );
    isLoading.value = false;
  }
}
