import 'usuario_entity.dart';

class UsuarioMapper {
  static Map<String, dynamic> toMap(Usuario u) => {
        'nome': u.nome,
        'email': u.email,
        'foto': u.foto,
        'provider': u.provider,
      };
}
