import 'package:carteira_server/carteira_server.dart';
import 'package:test/test.dart';

import '../../helpers.dart';

void main() {
  test('X-Delay-Ms forces the delay of a request', () async {
    final api = TestApi();
    final watch = Stopwatch()..start();
    final response = await api.send(
      'GET',
      '/health',
      headers: {'x-delay-ms': '120'},
    );
    expect(response.statusCode, 200);
    expect(watch.elapsedMilliseconds, greaterThanOrEqualTo(110));
  });

  test('configured latency delays every request', () async {
    final api = TestApi(latency: const LatencyConfig(minMs: 60, maxMs: 80));
    final watch = Stopwatch()..start();
    await api.send('GET', '/health');
    expect(watch.elapsedMilliseconds, greaterThanOrEqualTo(55));
  });

  test('fromEnvironment falls back to defaults and fixes inverted values', () {
    expect(LatencyConfig.fromEnvironment(const {}).minMs, 300);
    final fixed = LatencyConfig.fromEnvironment(const {
      'LATENCY_MIN_MS': '500',
      'LATENCY_MAX_MS': '100',
    });
    expect(fixed.maxMs, 500);
  });
}
