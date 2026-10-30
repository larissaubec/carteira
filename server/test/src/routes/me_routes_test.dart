import 'package:test/test.dart';

import '../../helpers.dart';

void main() {
  late TestApi api;
  late String token;

  setUp(() async {
    api = TestApi();
    token = await api.login();
  });

  test('GET /me returns the profile', () async {
    final json = await decode(await api.send('GET', '/me', token: token));
    expect(json['email'], 'ana@carteira.dev');
    expect(json['avatarUrl'], isNull);
  });

  test('PUT /me updates name and avatar', () async {
    final response = await api.send(
      'PUT',
      '/me',
      token: token,
      body: {'name': ' Ana R. ', 'avatarUrl': 'https://img/ana.png'},
    );
    expect(response.statusCode, 200);
    final json = await decode(response);
    expect(json['name'], 'Ana R.');
    expect(json['avatarUrl'], 'https://img/ana.png');
    expect(json['email'], 'ana@carteira.dev');
  });

  test('PUT /me rejects empty name', () async {
    final response = await api.send(
      'PUT',
      '/me',
      token: token,
      body: {'name': ''},
    );
    expect(response.statusCode, 422);
    expect(await errorFields(response), contains('name'));
  });
}
