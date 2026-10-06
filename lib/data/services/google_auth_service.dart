import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import 'auth_service.dart';

/// Autenticação com conta Google integrada ao Firebase Authentication.
abstract interface class IGoogleAuthService {
  Future<UsuarioResult> signInWithGoogle();
}

final class GoogleAuthService implements IGoogleAuthService {
  final FirebaseAuth _auth;

  GoogleAuthService({required FirebaseAuth firebaseAuth}) : _auth = firebaseAuth;

  @override
  Future<UsuarioResult> signInWithGoogle() async {
    final isDesktopSemSuporte = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux);
    if (isDesktopSemSuporte) {
      return Error(AuthFailure(
        'Login com Google não é suportado no Windows/Linux. '
        'Execute o app no Android, iOS ou Web (Chrome).',
      ));
    }

    try {
      final provider = GoogleAuthProvider();
      final cred = kIsWeb
          ? await _auth.signInWithPopup(provider)
          : await _auth.signInWithProvider(provider);
      final user = cred.user;
      if (user == null) return Error(AuthFailure());
      return Success(usuarioFromFirebase(user));
    } on FirebaseAuthException catch (e) {
      return Error(AuthFailure(authErrorMessage(e)));
    } catch (e) {
      return Error(AuthFailure('Erro ao entrar com Google: $e'));
    }
  }
}
