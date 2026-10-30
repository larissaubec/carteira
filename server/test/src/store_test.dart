import 'dart:math';

import 'package:carteira_server/carteira_server.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  late SessionStore store;

  setUp(() => store = SessionStore(loadSeed(), random: Random(1)));

  test('login returns a token for valid credentials', () {
    final token = store.login('ana@carteira.dev', '123456');
    expect(token, startsWith('tok_'));
    expect(store.find(token!), isNotNull);
  });

  test('login rejects wrong password and unknown email', () {
    expect(store.login('ana@carteira.dev', 'wrong'), isNull);
    expect(store.login('nobody@carteira.dev', '123456'), isNull);
  });

  test('each session gets its own copy of the seed', () {
    final first = store.login('ana@carteira.dev', '123456')!;
    final second = store.login('ana@carteira.dev', '123456')!;
    store.find(first)!.transactions.clear();
    expect(store.find(second)!.transactions, isNotEmpty);
    expect(store.seed.users[0].transactions, isNotEmpty);
  });

  test('reset restores the seed data', () {
    final token = store.login('ana@carteira.dev', '123456')!;
    store.find(token)!.transactions.clear();
    store.reset(token);
    expect(store.find(token)!.transactions, hasLength(60));
  });

  test('logout removes the session', () {
    final token = store.login('ana@carteira.dev', '123456')!;
    store.logout(token);
    expect(store.find(token), isNull);
  });

  test('generates sequential ids after the seed', () {
    final session = store.find(store.login('ana@carteira.dev', '123456')!)!;
    expect(session.nextTransactionId(), 'tx_0081');
    expect(session.nextTransactionId(), 'tx_0082');
  });
}
