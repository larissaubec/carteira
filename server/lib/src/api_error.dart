import 'package:shelf/shelf.dart';

import 'json.dart';

/// Erro conhecido da API, convertido na resposta padrão `{ "error": {...} }`.
class ApiError implements Exception {
  const ApiError(this.status, this.code, this.message, {this.fields});

  const ApiError.badRequest([String message = 'Malformed JSON body'])
    : this(400, 'bad_request', message);

  const ApiError.invalidCredentials()
    : this(401, 'invalid_credentials', 'Invalid email or password');

  const ApiError.unauthorized()
    : this(401, 'unauthorized', 'Missing or unknown token');

  const ApiError.tokenExpired()
    : this(401, 'token_expired', 'Token has expired');

  const ApiError.notFound(String message) : this(404, 'not_found', message);

  const ApiError.validation(String message, Map<String, String> fields)
    : this(422, 'validation', message, fields: fields);

  const ApiError.internal([String message = 'Internal server error'])
    : this(500, 'internal', message);

  final int status;
  final String code;
  final String message;
  final Map<String, String>? fields;

  Response toResponse() {
    final error = <String, Object?>{'code': code, 'message': message};
    if (fields != null) {
      error['fields'] = fields;
    }
    return jsonResponse({'error': error}, status: status);
  }

  @override
  String toString() => 'ApiError($status $code: $message)';
}
