/// Every way an operation can fail, as a closed hierarchy.
///
/// [message] is what the user sees, in Portuguese. The data layer never shows
/// raw exceptions to the UI: it maps them to one of these.
sealed class AppError {
  const AppError();

  String get message;

  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType && other.toString() == toString();

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() => '$runtimeType($message)';
}

/// No connection, DNS failure, connection refused.
final class NetworkError extends AppError {
  const NetworkError();

  @override
  String get message => 'Sem conexão. Verifique sua internet e tente de novo.';
}

/// The server took too long.
final class TimeoutError extends AppError {
  const TimeoutError();

  @override
  String get message => 'O servidor demorou demais para responder.';
}

/// Missing, unknown or expired token, or wrong credentials.
final class UnauthorizedError extends AppError {
  const UnauthorizedError({
    this.expired = false,
    this.invalidCredentials = false,
  });

  final bool expired;
  final bool invalidCredentials;

  @override
  String get message {
    if (invalidCredentials) return 'E-mail ou senha incorretos.';
    if (expired) return 'Sua sessão expirou. Entre novamente.';
    return 'Você precisa entrar para continuar.';
  }

  @override
  String toString() =>
      'UnauthorizedError(expired: $expired, invalidCredentials: $invalidCredentials)';
}

/// The resource does not exist (anymore).
final class NotFoundError extends AppError {
  const NotFoundError([this.resource]);

  final String? resource;

  @override
  String get message => resource == null
      ? 'Registro não encontrado.'
      : 'Registro não encontrado: $resource.';
}

/// The server rejected the payload. [fields] maps field name to message.
final class ValidationError extends AppError {
  const ValidationError(this.fields, {this.detail});

  final Map<String, String> fields;
  final String? detail;

  @override
  String get message => detail ?? 'Alguns campos estão inválidos.';

  @override
  String toString() => 'ValidationError($fields)';
}

/// 5xx.
final class ServerError extends AppError {
  const ServerError(this.statusCode);

  final int statusCode;

  @override
  String get message => 'Erro no servidor ($statusCode). Tente mais tarde.';
}

/// Anything not covered above. Keeps the original cause for logs.
final class UnknownError extends AppError {
  const UnknownError(this.cause);

  final Object cause;

  @override
  String get message => 'Algo deu errado. Tente novamente.';

  @override
  String toString() => 'UnknownError($cause)';
}

/// Carries an [AppError] through code that still uses exceptions (the HTTP
/// layer), so it can be turned back into a [Failure] at the boundary.
class AppException implements Exception {
  const AppException(this.error);

  final AppError error;

  @override
  String toString() => 'AppException($error)';
}
