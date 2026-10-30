import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../../helpers.dart';

void main() {
  late TestApi api;

  setUp(() => api = TestApi());

  test('login returns token and user without password', () async {
    final response = await api.send(
      'POST',
      '/auth/login',
      body: {'email': 'ana@carteira.dev', 'password': '123456'},
    );
    expect(response.statusCode, 200);
    expect(response.headers['content-type'], contains('application/json'));
    final json = await decode(response);
    expect(json['token'], startsWith('tok_'));
    final user = json['user'] as JsonMap;
    expect(user['name'], 'Ana Ribeiro');
    expect(user.containsKey('password'), isFalse);
  });

  test('login with wrong password returns 401 invalid_credentials', () async {
    final response = await api.send(
      'POST',
      '/auth/login',
      body: {'email': 'ana@carteira.dev', 'password': 'nope'},
    );
    expect(response.statusCode, 401);
    expect(await errorCode(response), 'invalid_credentials');
  });

  test('login with missing fields returns 422', () async {
    final response = await api.send('POST', '/auth/login', body: {'email': ''});
    expect(response.statusCode, 422);
    expect(await errorFields(response), contains('password'));
  });

  test('malformed JSON returns 400 bad_request', () async {
    final response = await api.handler(
      Request('POST', Uri.parse('http://localhost/auth/login'), body: '{oops'),
    );
    expect(response.statusCode, 400);
    expect(await errorCode(response), 'bad_request');
  });

  test('protected routes require a token', () async {
    final response = await api.send('GET', '/me');
    expect(response.statusCode, 401);
    expect(await errorCode(response), 'unauthorized');
  });

  test('unknown token is rejected', () async {
    final response = await api.send('GET', '/me', token: 'tok_fake');
    expect(response.statusCode, 401);
  });

  test('logout invalidates the token', () async {
    final token = await api.login();
    final logout = await api.send('POST', '/auth/logout', token: token);
    expect(logout.statusCode, 204);
    final after = await api.send('GET', '/me', token: token);
    expect(after.statusCode, 401);
  });

  test('health does not require a token', () async {
    final response = await api.send('GET', '/health');
    expect(response.statusCode, 200);
    expect((await decode(response))['status'], 'ok');
  });

  test('unknown routes return 404 not_found', () async {
    final token = await api.login();
    final response = await api.send('GET', '/nothing', token: token);
    expect(response.statusCode, 404);
    expect(await errorCode(response), 'not_found');
  });
}
