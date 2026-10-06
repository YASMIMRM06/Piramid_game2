class AppMessages {
  static const error = _Error();
}

class _Error {
  const _Error();
  final String defaultError = 'Ocorreu um erro inesperado.';
  final String inputError = 'Entrada inválida.';
  final String apiLocalError = 'Erro de armazenamento local.';
  final String emptyResultError = 'Nenhum resultado encontrado.';
  final String nullStringError = 'Valor nulo ou vazio não é permitido.';
  final String invalidDateError = 'Data inválida.';
  final String authError = 'Falha na autenticação.';
  final String remoteError = 'Erro ao acessar o servidor.';
  final String notAuthenticated =
      'É necessário estar autenticado para realizar esta ação.';
  final String selfEvaluation = 'Você não pode avaliar a si próprio.';
  final String permissionDenied =
      'Você não tem permissão para realizar esta ação.';
}
