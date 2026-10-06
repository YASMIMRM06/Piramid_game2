import 'package:flutter/foundation.dart';

import '../../core/typedefs/types_defs.dart';
import '../../domain/models/usuario_entity.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/google_auth_service.dart';
import 'auth_repository_interface.dart';

final class AuthRepositoryImpl implements IAuthRepository {
  final IAuthService _authService;
  final IGoogleAuthService _googleAuthService;
  final IFirestoreService _firestoreService;

  AuthRepositoryImpl({
    required IAuthService authService,
    required IGoogleAuthService googleAuthService,
    required IFirestoreService firestoreService,
  })  : _authService = authService,
        _googleAuthService = googleAuthService,
        _firestoreService = firestoreService;

  @override
  Usuario? get currentUser => _authService.currentUser;

  @override
  Future<UsuarioOptionalResult> restoreSession() =>
      _authService.restoreSession();

  @override
  Future<UsuarioResult> register(String email, String senha) async =>
      _persistirPerfil(await _authService.register(email, senha));

  @override
  Future<UsuarioResult> login(String email, String senha) async =>
      _persistirPerfil(await _authService.login(email, senha));

  @override
  Future<UsuarioResult> loginWithGoogle() async =>
      _persistirPerfil(await _googleAuthService.signInWithGoogle());

  @override
  Future<VoidResult> logout() => _authService.logout();

  /// Grava/atualiza o perfil do usuário na coleção `usuarios` do Firestore.
  /// Uma falha aqui não impede o login (o perfil é auxiliar).
  Future<UsuarioResult> _persistirPerfil(UsuarioResult resultado) async {
    final usuario = resultado.successValueOrNull;
    if (usuario != null) {
      final salvo = await _firestoreService.saveUsuario(usuario);
      if (salvo.isFailure) {
        debugPrint('[auth] Não foi possível salvar o perfil: '
            '${salvo.failureValueOrNull}');
      }
    }
    return resultado;
  }
}
