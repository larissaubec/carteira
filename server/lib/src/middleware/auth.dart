import 'package:shelf/shelf.dart';

import '../api_error.dart';
import '../store.dart';

const _sessionKey = 'carteira.session';
const _tokenKey = 'carteira.token';

/// Exige `Authorization: Bearer <token>` e anexa a sessão à requisição.
Middleware authMiddleware(SessionStore store) {
  return (inner) {
    return (request) {
      final header = request.headers['authorization'];
      if (header == null || !header.startsWith('Bearer ')) {
        throw const ApiError.unauthorized();
      }
      final token = header.substring('Bearer '.length).trim();
      final session = store.find(token);
      if (session == null) {
        throw const ApiError.unauthorized();
      }
      return inner(
        request.change(context: {_sessionKey: session, _tokenKey: token}),
      );
    };
  };
}

/// Acesso à sessão anexada por [authMiddleware].
extension SessionRequest on Request {
  SessionData get session => context[_sessionKey] as SessionData;
  String get token => context[_tokenKey] as String;
}
