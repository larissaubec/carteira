import 'package:carteira_core/carteira_core.dart';
import 'package:test/test.dart';

void main() {
  late InMemoryUserRepository repository;

  setUp(() => repository = InMemoryUserRepository());

  test('getProfile returns the sample user', () async {
    expect(await repository.getProfile(), Ok<User>(SampleData.user));
  });

  test('updateProfile trims the name and sets the avatar', () async {
    final result = await repository.updateProfile(
      name: '  Ana R. ',
      avatarUrl: 'https://x/a.png',
    );
    final user = result.valueOrNull!;
    expect(user.name, 'Ana R.');
    expect(user.avatarUrl, 'https://x/a.png');
    expect((await repository.getProfile()).valueOrNull, user);
  });

  test('updateProfile rejects an empty name', () async {
    final result = await repository.updateProfile(name: ' ');
    expect(result.errorOrNull, isA<ValidationError>());
  });
}
