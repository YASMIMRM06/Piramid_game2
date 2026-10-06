import '../models/avaliacao_entity.dart';
import '../models/pessoa_entity.dart';
import '../models/ranking_item.dart';

/// Cálculo puro (sem Firebase) dos rankings — fácil de testar.
class RankingCalculator {
  RankingCalculator._();

  /// Ranking pessoal: usa SOMENTE as avaliações feitas pelo usuário.
  /// [avaliacoesDoUsuario] deve conter apenas avaliações dele.
  static List<RankingItem> pessoal(
    List<Pessoa> pessoas,
    List<Avaliacao> avaliacoesDoUsuario,
  ) {
    final porId = {for (final p in pessoas) p.id: p};
    final itens = <RankingItem>[];
    for (final a in avaliacoesDoUsuario) {
      final pessoa = porId[a.pessoaId];
      if (pessoa == null) continue; // avaliação órfã
      itens.add(RankingItem(
        pessoa: pessoa,
        pontuacao: a.pontuacaoTotal.toDouble(),
        quantidadeAvaliacoes: 1,
      ));
    }
    itens.sort(_comparar);
    return itens;
  }

  /// Ranking global: média das avaliações recebidas por cada pessoa,
  /// da maior média para a menor. Pessoas sem avaliação não entram.
  static List<RankingItem> global(
    List<Pessoa> pessoas,
    List<Avaliacao> todasAvaliacoes,
  ) {
    final totais = <String, List<int>>{};
    for (final a in todasAvaliacoes) {
      (totais[a.pessoaId] ??= <int>[]).add(a.pontuacaoTotal);
    }

    final itens = <RankingItem>[];
    for (final pessoa in pessoas) {
      final notas = totais[pessoa.id];
      if (notas == null || notas.isEmpty) continue;
      final media = notas.reduce((a, b) => a + b) / notas.length;
      itens.add(RankingItem(
        pessoa: pessoa,
        pontuacao: media,
        quantidadeAvaliacoes: notas.length,
      ));
    }
    itens.sort(_comparar);
    return itens;
  }

  static int _comparar(RankingItem a, RankingItem b) {
    final porPontos = b.pontuacao.compareTo(a.pontuacao);
    if (porPontos != 0) return porPontos;
    final porQtd = b.quantidadeAvaliacoes.compareTo(a.quantidadeAvaliacoes);
    if (porQtd != 0) return porQtd;
    return a.pessoa.nome.compareTo(b.pessoa.nome);
  }
}
