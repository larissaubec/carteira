import 'package:shelf/shelf.dart';

const _corsHeaders = {
  'access-control-allow-origin': '*',
  'access-control-allow-methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
  'access-control-allow-headers':
      'Origin, Content-Type, Authorization, X-Delay-Ms, X-Fail',
};

/// Libera CORS para qualquer origem e responde preflight.
Middleware corsMiddleware() {
  return (inner) {
    return (request) async {
      if (request.method == 'OPTIONS') {
        return Response(204, headers: _corsHeaders);
      }
      final response = await inner(request);
      return response.change(headers: _corsHeaders);
    };
  };
}
