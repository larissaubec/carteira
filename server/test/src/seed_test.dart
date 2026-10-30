import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  final seed = loadSeed();

  test('loads both users from seed.json', () {
    expect(seed.users.map((u) => u.email), [
      'ana@carteira.dev',
      'bruno@carteira.dev',
    ]);
  });

  test('has the expected amount of transactions', () {
    expect(seed.users[0].transactions, hasLength(60));
    expect(seed.users[1].transactions, hasLength(20));
  });

  test('contains null categories and notes on purpose', () {
    final ana = seed.users[0].transactions;
    expect(ana.any((t) => t['category'] == null), isTrue);
    expect(ana.any((t) => t['note'] == null), isTrue);
    expect(ana.any((t) => t['type'] == 'transfer'), isTrue);
  });

  test('finds users by email ignoring case', () {
    expect(seed.findByEmail('ANA@carteira.dev')?.id, 'usr_01');
    expect(seed.findByEmail('nobody@carteira.dev'), isNull);
  });

  test('exposes the highest transaction number', () {
    expect(seed.maxTransactionNumber, 80);
  });

  test('public json never exposes the password', () {
    expect(seed.users[0].toPublicJson().containsKey('password'), isFalse);
  });
}
