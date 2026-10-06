import 'package:signals_flutter/signals_flutter.dart';

import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/auth_facade_usecases_interface.dart';
import '../../domain/models/usuario_entity.dart';
import '../commands/auth_commands.dart';

/// ViewModel de autenticação: mantém o usuário logado em um signal e
/// dispara as ações (login, cadastro, Google, logout) via Commands.
class AuthViewModel {
  final IAuthFacadeUseCases _facade;

  AuthViewModel(this._facade);

  // ── Estado reativo ─────────────────────────────────────────────
  final currentUser = signal<Usuario?>(null);
  final sessionChecked = signal<bool>(false);
  final message = signal<String?>(null);

  late final isAuthenticated = computed(() => currentUser.value != null);

  // ── Commands ───────────────────────────────────────────────────
  late final loginCommand = LoginCommand(_facade);
  late final registerCommand = RegisterCommand(_facade);
  late final loginGoogleCommand = LoginGoogleCommand(_facade);
  late final checkSessionCommand = CheckSessionCommand(_facade);
  late final logoutCommand = LogoutCommand(_facade);

  /// true enquanto qualquer ação de autenticação está em andamento.
  late final isBusy = computed(() =>
      loginCommand.isExecuting.value ||
      registerCommand.isExecuting.value ||
      loginGoogleCommand.isExecuting.value);

  // ── Ações chamadas pela UI ─────────────────────────────────────

  /// Verifica se existe uma autenticação válida (usado na Splash).
  Future<void> checkSession() async {
    final result = await checkSessionCommand.executeWith(());
    currentUser.value = result.successValueOrNull;
    sessionChecked.value = true;
  }

  Future<UsuarioResult> login(String email, String senha) =>
      _autenticar(() => loginCommand.executeWith((email: email, senha: senha)));

  Future<UsuarioResult> register(String email, String senha) => _autenticar(
      () => registerCommand.executeWith((email: email, senha: senha)));

  Future<UsuarioResult> loginWithGoogle() =>
      _autenticar(() => loginGoogleCommand.executeWith(()));

  Future<void> logout() async {
    await logoutCommand.executeWith(());
    currentUser.value = null;
    message.value = null;
  }

  Future<UsuarioResult> _autenticar(
      Future<UsuarioResult> Function() acao) async {
    message.value = null;
    final result = await acao();
    result.fold<void>(
      onSuccess: (usuario) {
        currentUser.value = usuario;
      },
      onFailure: (falha) {
        message.value = falha.msg;
      },
    );
    return result;
  }
}
