import 'avaliacao_entity.dart';

class AvaliacaoMapper {
  static Map<String, dynamic> toMap(Avaliacao a) => {
        'avaliadorUid': a.avaliadorUid,
        'pessoaId': a.pessoaId,
        for (final c in Criterio.values) c.name: a.notas[c] ?? Avaliacao.notaMin,
        'pontuacaoTotal': a.pontuacaoTotal,
        'dataAvaliacao': a.dataAvaliacao.toIso8601String(),
      };

  static Avaliacao fromMap(String id, Map<String, dynamic> map) => Avaliacao(
        id: id,
        avaliadorUid: map['avaliadorUid'] as String? ?? '',
        pessoaId: map['pessoaId'] as String? ?? '',
        notas: {
          for (final c in Criterio.values)
            c: (map[c.name] as num?)?.toInt() ?? Avaliacao.notaMin,
        },
        dataAvaliacao:
            DateTime.tryParse(map['dataAvaliacao'] as String? ?? '') ??
                DateTime.now(),
      );
}
