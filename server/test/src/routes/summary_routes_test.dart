import 'package:test/test.dart';

import '../../helpers.dart';

void main() {
  late TestApi api;
  late String token;

  setUp(() async {
    api = TestApi();
    token = await api.login();
  });

  test('GET /summary sums income and expense, ignoring transfers', () async {
    final json = await decode(
      await api.send('GET', '/summary?month=2026-08', token: token),
    );
    final august = api.seed.users[0].transactions.where(
      (t) => (t['date'] as String).startsWith('2026-08'),
    );
    double sum(String type) => august
        .where((t) => t['type'] == type)
        .fold(0, (total, t) => total + (t['amount'] as num));
    expect(august.any((t) => t['type'] == 'transfer'), isTrue);
    expect(json['month'], '2026-08');
    expect(json['income'], closeTo(sum('income'), 0.001));
    expect(json['expense'], closeTo(sum('expense'), 0.001));
    expect(
      json['balance'],
      closeTo((json['income'] as num) - (json['expense'] as num), 0.001),
    );
  });

  test('GET /summary rejects an invalid month', () async {
    final response = await api.send('GET', '/summary?month=2026', token: token);
    expect(response.statusCode, 422);
  });

  test('GET /summary defaults to the current month', () async {
    final json = await decode(await api.send('GET', '/summary', token: token));
    expect(json['month'], matches(r'^\d{4}-\d{2}$'));
  });
}
