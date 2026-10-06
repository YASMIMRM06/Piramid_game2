import 'package:equatable/equatable.dart';

/// Usuário autenticado (Firebase Authentication).
/// Não é a mesma coisa que [Pessoa] (quem recebe avaliações).
class Usuario extends Equatable {
  final String uid;
  final String nome;
  final String email;
  final String? foto;
  final String provider; // 'password' | 'google.com'

  const Usuario({
    required this.uid,
    required this.nome,
    required this.email,
    this.foto,
    required this.provider,
  });

  @override
  List<Object?> get props => [uid, nome, email, foto, provider];
}
