import 'package:carteira_core/carteira_core.dart';
import 'package:test/test.dart';

import 'fake_server.dart';

void main() {
  late FakeServer server;
  late ApiClient client;
  late InMemorySessionStorage storage;
  late RemoteAuthRepository repository;

  setUp(() {
    server = FakeServer();
    client = ApiClient(baseUrl: 'http://localhost:8080', client: server.client);
    storage = InMemorySessionStorage();
    repository = RemoteAuthRepository(client: client, storage: storage);
  });

  test(
    'login posts credentials, stores the session and sets the token',
    () async {
      server.on('POST', '/auth/login', 200, {
        'token': 'tok_abc',
        'user': SampleData.user.toJson(),
      });
      final result = await repository.login(
        email: ' ana@carteira.dev ',
        password: '123456',
      );
      expect(result.valueOrNull?.token, 'tok_abc');
      expect(server.lastBody, {
        'email': 'ana@carteira.dev',
        'password': '123456',
      });
      expect(client.token, 'tok_abc');
      expect(repository.currentSession?.user, SampleData.user);
      expect((await storage.read())?.token, 'tok_abc');
    },
  );

  test('login maps 401 to invalid credentials', () async {
    server.onError('POST', '/auth/login', 401, 'invalid_credentials');
    final result = await repository.login(email: 'a@b.c', password: 'x');
    expect(
      result,
      const Failure<Session>(UnauthorizedError(invalidCredentials: true)),
    );
    expect(client.token, isNull);
  });

  test(
    'logout posts and clears everything even when the server fails',
    () async {
      await storage.write(Session(token: 'tok_1', user: SampleData.user));
      await repository.restore();
      server.onError('POST', '/auth/logout', 401, 'unauthorized');
      final result = await repository.logout();
      expect(result.isFailure, isTrue);
      expect(server.last.headers['Authorization'], 'Bearer tok_1');
      expect(client.token, isNull);
      expect(repository.currentSession, isNull);
      expect(await storage.read(), isNull);
    },
  );

  test('logout succeeds on 204', () async {
    server.on('POST', '/auth/logout', 204);
    expect(await repository.logout(), const Ok<void>(null));
  });

  test('restore loads the stored session into the client', () async {
    final stored = Session(token: 'tok_9', user: SampleData.user);
    await storage.write(stored);
    expect(await repository.restore(), Ok<Session?>(stored));
    expect(client.token, 'tok_9');
    expect(repository.currentSession, stored);
  });

  test('restore returns null without a stored session', () async {
    expect(await repository.restore(), const Ok<Session?>(null));
    expect(client.token, isNull);
  });
}
