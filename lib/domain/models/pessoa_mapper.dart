import 'pessoa_entity.dart';

class PessoaMapper {
  static Map<String, dynamic> toMap(Pessoa p) => {
        'nome': p.nome,
        'apelido': p.apelido,
        'curso': p.curso.displayName,
        'turma': p.turmaAno,
        'dataNascimento': p.dataNascimento.toIso8601String(),
        'criadoPor': p.criadoPor,
        'usuarioUid': p.usuarioUid,
      };

  static Pessoa fromMap(String id, Map<String, dynamic> map) => Pessoa(
        id: id,
        nome: map['nome'] as String? ?? '',
        apelido: map['apelido'] as String? ?? '',
        curso: Curso.fromDisplayName(map['curso'] as String? ?? ''),
        turmaAno: (map['turma'] as num?)?.toInt() ?? Pessoa.turmaMax,
        dataNascimento:
            DateTime.tryParse(map['dataNascimento'] as String? ?? '') ??
                DateTime(2000),
        criadoPor: map['criadoPor'] as String? ?? '',
        usuarioUid: map['usuarioUid'] as String?,
      );
}
