import 'package:carteira_core/carteira_core.dart';
import 'package:test/test.dart';

import 'fake_server.dart';

void main() {
  late FakeServer server;
  late RemoteUserRepository repository;

  setUp(() {
    server = FakeServer();
    repository = RemoteUserRepository(
      client: ApiClient(
        baseUrl: 'http://localhost:8080',
        client: server.client,
      ),
    );
  });

  test('getProfile parses the user', () async {
    server.on('GET', '/me', 200, SampleData.user.toJson());
    expect(await repository.getProfile(), Ok<User>(SampleData.user));
  });

  test('updateProfile sends name and avatarUrl (null included)', () async {
    server.on(
      'PUT',
      '/me',
      200,
      SampleData.user.copyWith(name: 'Bia').toJson(),
    );
    final result = await repository.updateProfile(name: ' Bia ');
    expect(result.valueOrNull?.name, 'Bia');
    expect(server.lastBody, {'name': 'Bia', 'avatarUrl': null});
  });

  test('updateProfile maps 422', () async {
    server.on('PUT', '/me', 422, {
      'error': {
        'code': 'validation',
        'message': 'Invalid profile',
        'fields': {'name': 'must not be empty'},
      },
    });
    final result = await repository.updateProfile(name: '');
    expect(
      result.errorOrNull,
      const ValidationError({
        'name': 'must not be empty',
      }, detail: 'Invalid profile'),
    );
  });

  test('unauthorized propagates', () async {
    server.onError('GET', '/me', 401, 'token_expired');
    expect(
      (await repository.getProfile()).errorOrNull,
      const UnauthorizedError(expired: true),
    );
  });
}
