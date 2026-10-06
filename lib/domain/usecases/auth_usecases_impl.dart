import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/auth_repository_interface.dart';
import 'auth_usecases_interfaces.dart';

final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Regras de negócio comuns ao cadastro e ao login.
Failure? _validarCredenciais(CredenciaisParams p, {required bool cadastro}) {
  if (!_emailRegex.hasMatch(p.email.trim())) {
    return InputFailure('Informe um e-mail válido.');
  }
  if (p.senha.isEmpty) {
    return InputFailure('Informe a senha.');
  }
  if (cadastro && p.senha.length < 6) {
    return InputFailure('A senha deve ter pelo menos 6 caracteres.');
  }
  return null;
}

final class RegisterUserUseCaseImpl implements IRegisterUserUseCase {
  final IAuthRepository _repository;
  RegisterUserUseCaseImpl({required IAuthRepository repository})
      : _repository = repository;

  @override
  Future<UsuarioResult> call(CredenciaisParams params) async {
    final erro = _validarCredenciais(params, cadastro: true);
    if (erro != null) return Error(erro);
    return _repository.register(params.email, params.senha);
  }
}

final class LoginUseCaseImpl implements ILoginUseCase {
  final IAuthRepository _repository;
  LoginUseCaseImpl({required IAuthRepository repository})
      : _repository = repository;

  @override
  Future<UsuarioResult> call(CredenciaisParams params) async {
    final erro = _validarCredenciais(params, cadastro: false);
    if (erro != null) return Error(erro);
    return _repository.login(params.email, params.senha);
  }
}

final class LoginGoogleUseCaseImpl implements ILoginGoogleUseCase {
  final IAuthRepository _repository;
  LoginGoogleUseCaseImpl({required IAuthRepository repository})
      : _repository = repository;

  @override
  Future<UsuarioResult> call(NoParams params) => _repository.loginWithGoogle();
}

final class CheckAuthenticatedUseCaseImpl implements ICheckAuthenticatedUseCase {
  final IAuthRepository _repository;
  CheckAuthenticatedUseCaseImpl({required IAuthRepository repository})
      : _repository = repository;

  @override
  Future<UsuarioOptionalResult> call(NoParams params) =>
      _repository.restoreSession();
}

final class LogoutUseCaseImpl implements ILogoutUseCase {
  final IAuthRepository _repository;
  LogoutUseCaseImpl({required IAuthRepository repository})
      : _repository = repository;

  @override
  Future<VoidResult> call(NoParams params) => _repository.logout();
}
