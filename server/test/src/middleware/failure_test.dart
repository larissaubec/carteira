import 'package:test/test.dart';

import '../../helpers.dart';

void main() {
  late TestApi api;
  late String token;

  setUp(() async {
    api = TestApi();
    token = await api.login();
  });

  test('X-Fail: 500 returns internal error', () async {
    final response = await api.send(
      'GET',
      '/me',
      token: token,
      headers: {'x-fail': '500'},
    );
    expect(response.statusCode, 500);
    expect(await errorCode(response), 'internal');
  });

  test(
    'X-Fail: expired returns 401 token_expired even with valid token',
    () async {
      final response = await api.send(
        'GET',
        '/me',
        token: token,
        headers: {'x-fail': 'expired'},
      );
      expect(response.statusCode, 401);
      expect(await errorCode(response), 'token_expired');
    },
  );

  test(
    'X-Fail: timeout holds the request for the configured duration',
    () async {
      final watch = Stopwatch()..start();
      final response = await api.send(
        'GET',
        '/health',
        headers: {'x-fail': 'timeout'},
      );
      expect(response.statusCode, 504);
      expect(watch.elapsedMilliseconds, greaterThanOrEqualTo(45));
    },
  );
}
