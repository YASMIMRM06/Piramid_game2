import 'package:flutter_test/flutter_test.dart';

import 'package:piramid_game/domain/models/avaliacao_entity.dart';
import 'package:piramid_game/domain/models/pessoa_entity.dart';
import 'package:piramid_game/domain/usecases/ranking_calculator.dart';

Pessoa _pessoa(String id, String nome) => Pessoa(
      id: id,
      nome: nome,
      apelido: nome,
      curso: Curso.tads,
      turmaAno: 2024,
      dataNascimento: DateTime(2004, 1, 1),
      criadoPor: 'u1',
    );

/// Cria uma avaliação em que todos os critérios têm a mesma nota base,
/// ajustando o primeiro critério para obter exatamente [total] pontos.
Avaliacao _avaliacao(String avaliador, String pessoaId, int total) {
  final notas = {for (final c in Criterio.values) c: 1};
  var restante = total - Criterio.values.length;
  for (final c in Criterio.values) {
    final extra = restante > 4 ? 4 : restante;
    notas[c] = 1 + extra;
    restante -= extra;
  }
  return Avaliacao(
    id: Avaliacao.buildId(avaliador, pessoaId),
    avaliadorUid: avaliador,
    pessoaId: pessoaId,
    notas: notas,
    dataAvaliacao: DateTime(2026, 9, 29),
  );
}

void main() {
  group('Avaliacao', () {
    test('pontuação total é a soma dos 15 critérios (15 a 75)', () {
      expect(_avaliacao('u1', 'p1', 15).pontuacaoTotal, 15);
      expect(_avaliacao('u1', 'p1', 58).pontuacaoTotal, 58);
      expect(_avaliacao('u1', 'p1', 75).pontuacaoTotal, 75);
    });

    test('id é único por usuário + pessoa', () {
      expect(Avaliacao.buildId('u1', 'p1'), 'u1_p1');
    });

    test('rejeita notas fora de 1..5 ou critérios faltando', () {
      final ok = {for (final c in Criterio.values) c: 3};
      expect(Avaliacao.notasValidas(ok), isTrue);
      expect(Avaliacao.notasValidas({...ok, Criterio.aura: 0}), isFalse);
      expect(Avaliacao.notasValidas({...ok, Criterio.aura: 6}), isFalse);
      expect(Avaliacao.notasValidas({...ok}..remove(Criterio.aura)), isFalse);
    });

    test('são 15 critérios', () {
      expect(Criterio.values.length, 15);
    });
  });

  group('RankingCalculator', () {
    final ana = _pessoa('ana', 'Ana');
    final joao = _pessoa('joao', 'João');
    final maria = _pessoa('maria', 'Maria');
    final pessoas = [ana, joao, maria];

    test('ranking pessoal ordena pelas notas do usuário', () {
      final r = RankingCalculator.pessoal(pessoas, [
        _avaliacao('u1', 'joao', 58),
        _avaliacao('u1', 'ana', 68),
        _avaliacao('u1', 'maria', 54),
      ]);
      expect(r.map((e) => e.pessoa.nome), ['Ana', 'João', 'Maria']);
      expect(r.map((e) => e.pontuacao), [68, 58, 54]);
    });

    test('ranking global usa a média e conta as avaliações', () {
      final r = RankingCalculator.global(pessoas, [
        _avaliacao('u1', 'ana', 60),
        _avaliacao('u2', 'ana', 70),
        _avaliacao('u3', 'ana', 65),
        _avaliacao('u1', 'joao', 50),
      ]);
      expect(r.first.pessoa.nome, 'Ana');
      expect(r.first.pontuacao, 65);
      expect(r.first.quantidadeAvaliacoes, 3);
      expect(r.last.pessoa.nome, 'João');
    });

    test('pessoas sem avaliação não entram no ranking global', () {
      final r = RankingCalculator.global(pessoas, [_avaliacao('u1', 'ana', 60)]);
      expect(r.length, 1);
    });
  });
}
