import 'package:equatable/equatable.dart';

enum Curso {
  info,
  mec,
  mamb,
  prod,
  tads,
  tga;

  String get displayName => name.toUpperCase();

  static Curso fromDisplayName(String value) => Curso.values.firstWhere(
        (c) => c.displayName == value.toUpperCase(),
        orElse: () => Curso.info,
      );
}

/// Pessoa que pode receber avaliações. Não possui notas: elas ficam em
/// [Avaliacao]. Pode (ou não) estar vinculada a um usuário autenticado
/// através de [usuarioUid] — usado para impedir a autoavaliação.
class Pessoa extends Equatable {
  static const int turmaMin = 1998;
  static const int turmaMax = 2026;

  final String id;
  final String nome;
  final String apelido;
  final Curso curso;
  final int turmaAno;
  final DateTime dataNascimento;
  final String criadoPor; // uid de quem cadastrou
  final String? usuarioUid; // uid do usuário que É esta pessoa (opcional)

  const Pessoa({
    required this.id,
    required this.nome,
    required this.apelido,
    required this.curso,
    required this.turmaAno,
    required this.dataNascimento,
    required this.criadoPor,
    this.usuarioUid,
  });

  Pessoa copyWith({
    String? id,
    String? nome,
    String? apelido,
    Curso? curso,
    int? turmaAno,
    DateTime? dataNascimento,
    String? criadoPor,
    String? usuarioUid,
    bool removerVinculo = false,
  }) {
    return Pessoa(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      apelido: apelido ?? this.apelido,
      curso: curso ?? this.curso,
      turmaAno: turmaAno ?? this.turmaAno,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      criadoPor: criadoPor ?? this.criadoPor,
      usuarioUid: removerVinculo ? null : (usuarioUid ?? this.usuarioUid),
    );
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        apelido,
        curso,
        turmaAno,
        dataNascimento,
        criadoPor,
        usuarioUid,
      ];

  @override
  String toString() =>
      'Pessoa(id: $id, nome: $nome, curso: ${curso.displayName}, turmaAno: $turmaAno)';
}
