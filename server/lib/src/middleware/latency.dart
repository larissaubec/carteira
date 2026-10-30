import 'dart:math';

import 'package:shelf/shelf.dart';

import '../latency.dart';

/// Atrasa cada resposta por um tempo aleatório dentro da configuração,
/// ou pelo valor exato de `X-Delay-Ms` quando presente.
Middleware latencyMiddleware(LatencyConfig config, {Random? random}) {
  final rng = random ?? Random();
  return (inner) {
    return (request) async {
      final delay = _delayFor(request, config, rng);
      if (delay > 0) {
        await Future<void>.delayed(Duration(milliseconds: delay));
      }
      return inner(request);
    };
  };
}

int _delayFor(Request request, LatencyConfig config, Random rng) {
  final forced = int.tryParse(request.headers['x-delay-ms'] ?? '');
  if (forced != null && forced >= 0) {
    return forced;
  }
  if (config.maxMs == 0) {
    return 0;
  }
  return config.minMs + rng.nextInt(config.maxMs - config.minMs + 1);
}
