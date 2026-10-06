import '../messages/app_messages.dart';

sealed class Failure implements Exception {
  final String msg;
  Failure(this.msg);

  @override
  String toString() => '$runtimeType: $msg';
}

class DefaultFailure extends Failure {
  DefaultFailure([String? msg]) : super(msg ?? AppMessages.error.defaultError);
}

class ApiLocalFailure extends Failure {
  ApiLocalFailure([String? msg])
      : super(msg ?? AppMessages.error.apiLocalError);
}

class EmptyResultFailure extends Failure {
  EmptyResultFailure([String? msg])
      : super(msg ?? AppMessages.error.emptyResultError);
}

class InputFailure extends Failure {
  InputFailure([String? msg]) : super(msg ?? AppMessages.error.inputError);
}

class AuthFailure extends Failure {
  AuthFailure([String? msg]) : super(msg ?? AppMessages.error.authError);
}

class RemoteFailure extends Failure {
  RemoteFailure([String? msg]) : super(msg ?? AppMessages.error.remoteError);
}
