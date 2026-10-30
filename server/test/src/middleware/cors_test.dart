import 'package:test/test.dart';

import '../../helpers.dart' show TestApi;

void main() {
  test('OPTIONS preflight returns 204 with CORS headers', () async {
    final response = await TestApi().send('OPTIONS', '/transactions');
    expect(response.statusCode, 204);
    expect(response.headers['access-control-allow-origin'], '*');
  });

  test('normal responses carry CORS headers', () async {
    final response = await TestApi().send('GET', '/health');
    expect(response.headers['access-control-allow-origin'], '*');
  });
}
