import 'package:carteira_core/carteira_core.dart';
import 'package:test/test.dart';

void main() {
  final json = <String, Object?>{
    'id': 'usr_01',
    'name': 'Ana Ribeiro',
    'email': 'ana@carteira.dev',
    'avatarUrl': null,
    'createdAt': '2024-03-11T09:00:00Z',
  };

  group('User.fromJson', () {
    test('parses required fields and null avatar', () {
      final user = User.fromJson(json);
      expect(user.id, 'usr_01');
      expect(user.avatarUrl, isNull);
      expect(user.createdAt, DateTime.utc(2024, 3, 11, 9));
      expect(user.createdAt.isUtc, isTrue);
    });

    test('accepts a missing avatarUrl key', () {
      final user = User.fromJson({...json}..remove('avatarUrl'));
      expect(user.avatarUrl, isNull);
    });

    test('keeps a present avatarUrl', () {
      final user = User.fromJson({...json, 'avatarUrl': 'https://x/a.png'});
      expect(user.avatarUrl, 'https://x/a.png');
    });

    test('throws on a missing required field', () {
      expect(
        () => User.fromJson({...json}..remove('email')),
        throwsFormatException,
      );
    });
  });

  test('toJson round-trips', () {
    final user = User.fromJson(json);
    expect(User.fromJson(user.toJson()), user);
  });

  test('initials use first and last name', () {
    expect(User.fromJson(json).initials, 'AR');
    expect(User.fromJson({...json, 'name': 'Ana'}).initials, 'A');
  });

  test('copyWith can clear the avatar', () {
    final user = User.fromJson({...json, 'avatarUrl': 'https://x/a.png'});
    expect(user.copyWith(avatarUrl: () => null).avatarUrl, isNull);
    expect(user.copyWith(name: 'Bia').name, 'Bia');
  });
}
