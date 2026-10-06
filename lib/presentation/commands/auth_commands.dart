import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart' as r;
import '../../core/typedefs/types_defs.dart';
import '../../domain/facades/auth_facade_usecases_interface.dart';
import '../../domain/models/usuario_entity.dart';

final class LoginCommand
    extends ParameterizedCommand<Usuario, Failure, CredenciaisParams> {
  final IAuthFacadeUseCases _facade;
  LoginCommand(this._facade);

  @override
  Future<UsuarioResult> execute() async {
    final p = parameter;
    if (p == null) return r.Error(InputFailure());
    return _facade.login(p);
  }
}

final class RegisterCommand
    extends ParameterizedCommand<Usuario, Failure, CredenciaisParams> {
  final IAuthFacadeUseCases _facade;
  RegisterCommand(this._facade);

  @override
  Future<UsuarioResult> execute() async {
    final p = parameter;
    if (p == null) return r.Error(InputFailure());
    return _facade.criarConta(p);
  }
}

final class LoginGoogleCommand
    extends ParameterizedCommand<Usuario, Failure, NoParams> {
  final IAuthFacadeUseCases _facade;
  LoginGoogleCommand(this._facade);

  @override
  Future<UsuarioResult> execute() => _facade.loginComGoogle(());
}

final class CheckSessionCommand
    extends ParameterizedCommand<Usuario?, Failure, NoParams> {
  final IAuthFacadeUseCases _facade;
  CheckSessionCommand(this._facade);

  @override
  Future<UsuarioOptionalResult> execute() => _facade.verificarAutenticacao(());
}

final class LogoutCommand extends ParameterizedCommand<void, Failure, NoParams> {
  final IAuthFacadeUseCases _facade;
  LogoutCommand(this._facade);

  @override
  Future<VoidResult> execute() => _facade.logout(());
}
