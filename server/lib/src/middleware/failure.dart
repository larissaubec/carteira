import 'package:shelf/shelf.dart';

import '../api_error.dart';
import '../latency.dart';

/// Simula falhas a pedido do cliente pelo cabeçalho `X-Fail`.
///
/// - `500`: responde `500 internal`.
/// - `timeout`: segura a requisição por [LatencyConfig.timeout] e fecha.
/// - `expired`: responde `401 token_expired`.
Middleware failureMiddleware(LatencyConfig config) {
  return (inner) {
    return (request) async {
      switch (request.headers['x-fail']?.trim().toLowerCase()) {
        case '500':
          throw const ApiError.internal('Simulated failure');
        case 'expired':
          throw const ApiError.tokenExpired();
        case 'timeout':
          await Future<void>.delayed(config.timeout);
          return Response(504, body: 'Simulated timeout');
        default:
          return inner(request);
      }
    };
  };
}
