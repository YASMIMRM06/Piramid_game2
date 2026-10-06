import '../../core/typedefs/types_defs.dart';
import '../usecases/auth_usecases_interfaces.dart';
import 'auth_facade_usecases_interface.dart';

final class AuthFacadeUseCasesImpl implements IAuthFacadeUseCases {
  final IRegisterUserUseCase _register;
  final ILoginUseCase _login;
  final ILoginGoogleUseCase _loginGoogle;
  final ICheckAuthenticatedUseCase _check;
  final ILogoutUseCase _logout;

  AuthFacadeUseCasesImpl({
    required IRegisterUserUseCase registerUserUseCase,
    required ILoginUseCase loginUseCase,
    required ILoginGoogleUseCase loginGoogleUseCase,
    required ICheckAuthenticatedUseCase checkAuthenticatedUseCase,
    required ILogoutUseCase logoutUseCase,
  })  : _register = registerUserUseCase,
        _login = loginUseCase,
        _loginGoogle = loginGoogleUseCase,
        _check = checkAuthenticatedUseCase,
        _logout = logoutUseCase;

  @override
  Future<UsuarioResult> criarConta(CredenciaisParams params) => _register(params);

  @override
  Future<UsuarioResult> login(CredenciaisParams params) => _login(params);

  @override
  Future<UsuarioResult> loginComGoogle(NoParams params) => _loginGoogle(params);

  @override
  Future<UsuarioOptionalResult> verificarAutenticacao(NoParams params) =>
      _check(params);

  @override
  Future<VoidResult> logout(NoParams params) => _logout(params);
}
