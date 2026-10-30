import 'package:carteira_core/carteira_core.dart';
import 'package:test/test.dart';

void main() {
  test('balance is income minus expense', () {
    const summary = Summary(month: '2026-09', income: 100, expense: 30.5);
    expect(summary.balance, 69.5);
  });

  test('fromJson accepts integers as amounts', () {
    final summary = Summary.fromJson({
      'month': '2026-09',
      'income': 100,
      'expense': 30,
      'balance': 70,
    });
    expect(summary.income, 100.0);
    expect(summary.balance, 70.0);
  });
}
