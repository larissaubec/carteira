/// Configuração da latência simulada.
class LatencyConfig {
  const LatencyConfig({
    this.minMs = 300,
    this.maxMs = 800,
    this.timeout = const Duration(seconds: 60),
  }) : assert(minMs >= 0, 'minMs must be >= 0'),
       assert(maxMs >= minMs, 'maxMs must be >= minMs');

  /// Lê `LATENCY_MIN_MS` e `LATENCY_MAX_MS` do ambiente.
  factory LatencyConfig.fromEnvironment(Map<String, String> env) {
    final min = int.tryParse(env['LATENCY_MIN_MS'] ?? '') ?? 300;
    final max = int.tryParse(env['LATENCY_MAX_MS'] ?? '') ?? 800;
    return LatencyConfig(minMs: min, maxMs: max < min ? min : max);
  }

  /// Sem latência, para testes.
  static const none = LatencyConfig(
    minMs: 0,
    maxMs: 0,
    timeout: Duration(milliseconds: 50),
  );

  final int minMs;
  final int maxMs;

  /// Quanto tempo `X-Fail: timeout` segura a requisição antes de fechar.
  final Duration timeout;
}
