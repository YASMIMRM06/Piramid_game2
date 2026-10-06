import '../../core/typedefs/types_defs.dart';
import '../../domain/models/usuario_entity.dart';

abstract interface class IAuthRepository {
  Usuario? get currentUser;
  Future<UsuarioOptionalResult> restoreSession();
  Future<UsuarioResult> register(String email, String senha);
  Future<UsuarioResult> login(String email, String senha);
  Future<UsuarioResult> loginWithGoogle();
  Future<VoidResult> logout();
}
