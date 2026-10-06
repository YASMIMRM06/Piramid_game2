import 'package:equatable/equatable.dart';

import 'pessoa_entity.dart';

/// Linha de um ranking (pessoal ou global).
/// - Pessoal: [pontuacao] = Nível Lenda dado pelo usuário, [quantidadeAvaliacoes] = 1.
/// - Global: [pontuacao] = média das avaliações recebidas.
class RankingItem extends Equatable {
  final Pessoa pessoa;
  final double pontuacao;
  final int quantidadeAvaliacoes;

  const RankingItem({
    required this.pessoa,
    required this.pontuacao,
    required this.quantidadeAvaliacoes,
  });

  @override
  List<Object?> get props => [pessoa, pontuacao, quantidadeAvaliacoes];
}
