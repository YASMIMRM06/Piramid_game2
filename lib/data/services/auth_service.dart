import 'package:firebase_auth/firebase_auth.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/usuario_entity.dart';

/// Comunicação direta com o Firebase Authentication (e-mail e senha).
abstract interface class IAuthService {
  /// Usuário atual (síncrono). Use [restoreSession] ao abrir o app.
  Usuario? get currentUser;

  /// Aguarda o Firebase restaurar a sessão salva (necessário principalmente na Web).
  Future<UsuarioOptionalResult> restoreSession();

  Future<UsuarioResult> register(String email, String senha);
  Future<UsuarioResult> login(String email, String senha);
  Future<VoidResult> logout();
}

/// Converte o [User] do Firebase para a entidade de domínio [Usuario].
Usuario usuarioFromFirebase(User user) {
  final email = user.email ?? '';
  final displayName = user.displayName?.trim() ?? '';
  final nome = displayName.isNotEmpty
      ? displayName
      : (email.contains('@') ? email.split('@').first : 'Usuário');
  final provider =
      user.providerData.isNotEmpty ? user.providerData.first.providerId : 'password';

  return Usuario(
    uid: user.uid,
    nome: nome,
    email: email,
    foto: user.photoURL,
    provider: provider,
  );
}

/// Traduz os códigos de erro do Firebase Auth para mensagens amigáveis.
String authErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'E-mail inválido.';
    case 'user-disabled':
      return 'Esta conta foi desativada.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'E-mail ou senha incorretos.';
    case 'email-already-in-use':
      return 'Este e-mail já está cadastrado.';
    case 'weak-password':
      return 'Senha muito fraca (use pelo menos 6 caracteres).';
    case 'network-request-failed':
      return 'Sem conexão com a internet.';
    case 'too-many-requests':
      return 'Muitas tentativas. Tente novamente mais tarde.';
    case 'operation-not-allowed':
      return 'Este método de login não está habilitado no Firebase Console.';
    case 'popup-closed-by-user':
    case 'cancelled-popup-request':
    case 'canceled':
    case 'web-context-canceled':
      return 'Login com Google cancelado.';
    default:
      return 'Erro de autenticação (${e.code}).';
  }
}

final class AuthService implements IAuthService {
  final FirebaseAuth _auth;

  AuthService({required FirebaseAuth firebaseAuth}) : _auth = firebaseAuth;

  @override
  Usuario? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : usuarioFromFirebase(user);
  }

  @override
  Future<UsuarioOptionalResult> restoreSession() async {
    try {
      final user = await _auth.authStateChanges().first;
      return Success(user == null ? null : usuarioFromFirebase(user));
    } catch (e) {
      return Error(AuthFailure('Erro ao verificar autenticação: $e'));
    }
  }

  @override
  Future<UsuarioResult> register(String email, String senha) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      final user = cred.user;
      if (user == null) return Error(AuthFailure());
      return Success(usuarioFromFirebase(user));
    } on FirebaseAuthException catch (e) {
      return Error(AuthFailure(authErrorMessage(e)));
    } catch (e) {
      return Error(AuthFailure('Erro ao criar conta: $e'));
    }
  }

  @override
  Future<UsuarioResult> login(String email, String senha) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      final user = cred.user;
      if (user == null) return Error(AuthFailure());
      return Success(usuarioFromFirebase(user));
    } on FirebaseAuthException catch (e) {
      return Error(AuthFailure(authErrorMessage(e)));
    } catch (e) {
      return Error(AuthFailure('Erro ao entrar: $e'));
    }
  }

  @override
  Future<VoidResult> logout() async {
    try {
      await _auth.signOut();
      return const Success(null);
    } catch (e) {
      return Error(AuthFailure('Erro ao sair: $e'));
    }
  }
}
