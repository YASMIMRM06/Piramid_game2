import '../../core/patterns/i_usecases.dart';
import '../../core/typedefs/types_defs.dart';

abstract interface class IRegisterUserUseCase
    implements IUseCase<UsuarioResult, CredenciaisParams> {}

abstract interface class ILoginUseCase
    implements IUseCase<UsuarioResult, CredenciaisParams> {}

abstract interface class ILoginGoogleUseCase
    implements IUseCase<UsuarioResult, NoParams> {}

abstract interface class ICheckAuthenticatedUseCase
    implements IUseCase<UsuarioOptionalResult, NoParams> {}

abstract interface class ILogoutUseCase
    implements IUseCase<VoidResult, NoParams> {}
