import 'package:carteira_core/carteira_core.dart';
import 'package:test/test.dart';

void main() {
  late InMemoryAuthRepository repository;
  late InMemorySessionStorage storage;

  setUp(() {
    storage = InMemorySessionStorage();
    repository = InMemoryAuthRepository(storage: storage);
  });

  test('login succeeds with the sample credentials', () async {
    final result = await repository.login(
      email: 'ANA@carteira.dev ',
      password: SampleData.password,
    );
    expect(result, isA<Ok<Session>>());
    expect(repository.currentSession?.user, SampleData.user);
    expect(await storage.read(), isNotNull);
  });

  test('login fails with wrong password', () async {
    final result = await repository.login(
      email: SampleData.user.email,
      password: 'nope',
    );
    expect(
      result,
      const Failure<Session>(UnauthorizedError(invalidCredentials: true)),
    );
    expect(repository.currentSession, isNull);
  });

  test('logout clears the session and storage', () async {
    await repository.login(
      email: SampleData.user.email,
      password: SampleData.password,
    );
    expect(await repository.logout(), isA<Ok<void>>());
    expect(repository.currentSession, isNull);
    expect(await storage.read(), isNull);
  });

  test('restore reads the stored session', () async {
    final stored = Session(token: 'tok_x', user: SampleData.user);
    await storage.write(stored);
    final result = await repository.restore();
    expect(result, Ok<Session?>(stored));
    expect(repository.currentSession, stored);
  });

  test('restore returns null when nothing is stored', () async {
    expect(await repository.restore(), const Ok<Session?>(null));
  });
}
