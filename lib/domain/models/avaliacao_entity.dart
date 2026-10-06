import 'package:equatable/equatable.dart';

/// Os 15 critérios de popularidade. O `name` de cada valor é usado como
/// nome do campo no Firestore (mesmos nomes da especificação).
enum Criterio {
  resenha('Resenha'),
  presencaVip('Presença VIP'),
  aura('Aura'),
  modoParceiro('Modo Parceiro'),
  carismaNatural('Carisma Natural'),
  humorDeMilhoes('Humor de Milhões'),
  energiaDeGrupo('Energia de Grupo'),
  criatividadeCaotica('Criatividade Caótica'),
  modoAtleta('Modo Atleta'),
  talentoDePalco('Talento de Palco'),
  dripEscolar('Drip Escolar'),
  coracaoDeDorama('Coração de Dorama'),
  queridinhoProfessores('Queridinho dos Professores'),
  cerebroTurbo('Cérebro Turbo'),
  caosControlado('Caos Controlado');

  final String label;
  const Criterio(this.label);
}

/// Avaliação de UMA pessoa feita por UM usuário.
/// O id é determinístico (`avaliadorUid_pessoaId`), o que garante no próprio
/// Firestore a regra "usuário + pessoa avaliada = uma avaliação".
class Avaliacao extends Equatable {
  static const int notaMin = 1;
  static const int notaMax = 5;
  static const int pontuacaoMin = 15; // 15 x 1
  static const int pontuacaoMax = 75; // 15 x 5

  final String id;
  final String avaliadorUid;
  final String pessoaId;
  final Map<Criterio, int> notas;
  final DateTime dataAvaliacao;

  const Avaliacao({
    required this.id,
    required this.avaliadorUid,
    required this.pessoaId,
    required this.notas,
    required this.dataAvaliacao,
  });

  static String buildId(String avaliadorUid, String pessoaId) =>
      '${avaliadorUid}_$pessoaId';

  /// Nível Lenda = soma das notas dos 15 critérios (calculado automaticamente).
  int get pontuacaoTotal => notas.values.fold(0, (soma, n) => soma + n);

  /// true se todos os 15 critérios existem e estão entre 1 e 5.
  static bool notasValidas(Map<Criterio, int> notas) => Criterio.values.every(
        (c) {
          final n = notas[c];
          return n != null && n >= notaMin && n <= notaMax;
        },
      );

  @override
  List<Object?> get props =>
      [id, avaliadorUid, pessoaId, notas, dataAvaliacao];
}
