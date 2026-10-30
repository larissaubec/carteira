import 'package:carteira_core/carteira_core.dart';
import 'package:test/test.dart';

void main() {
  final expenseJson = <String, Object?>{
    'id': 'tx_0042',
    'type': 'expense',
    'amount': 89.9,
    'description': 'Mercado',
    'category': 'Alimentação',
    'date': '2026-09-06T14:32:00Z',
    'note': null,
    'account': 'Nubank',
    'toAccount': null,
  };

  group('Transaction.fromJson', () {
    test('builds the subclass from the type field', () {
      expect(Transaction.fromJson(expenseJson), isA<Expense>());
      expect(
        Transaction.fromJson({...expenseJson, 'type': 'income'}),
        isA<Income>(),
      );
      expect(
        Transaction.fromJson({
          ...expenseJson,
          'type': 'transfer',
          'toAccount': 'Itaú',
        }),
        isA<Transfer>(),
      );
    });

    test('converts integer amounts to double', () {
      final t = Transaction.fromJson({...expenseJson, 'amount': 90});
      expect(t.amount, 90.0);
      expect(t.amount, isA<double>());
    });

    test('treats null, empty and missing optional fields the same', () {
      final withNull = Transaction.fromJson(expenseJson);
      final withEmpty = Transaction.fromJson({...expenseJson, 'note': ''});
      final missing = Transaction.fromJson({...expenseJson}..remove('note'));
      expect(withNull.note, isNull);
      expect(withEmpty.note, isNull);
      expect(missing.note, isNull);
    });

    test('parses the date as UTC', () {
      final t = Transaction.fromJson(expenseJson);
      expect(t.date, DateTime.utc(2026, 9, 6, 14, 32));
      expect(t.date.isUtc, isTrue);
    });

    test('rejects an unknown type', () {
      expect(
        () => Transaction.fromJson({...expenseJson, 'type': 'loan'}),
        throwsFormatException,
      );
    });

    test('requires toAccount for transfers', () {
      expect(
        () => Transaction.fromJson({...expenseJson, 'type': 'transfer'}),
        throwsFormatException,
      );
    });
  });

  group('polymorphism', () {
    final income = Income(
      id: 'a',
      amount: 10,
      description: 'x',
      date: DateTime.utc(2026),
      account: 'A',
    );
    final expense = Expense(
      id: 'b',
      amount: 10,
      description: 'x',
      date: DateTime.utc(2026),
      account: 'A',
    );
    final transfer = Transfer(
      id: 'c',
      amount: 10,
      description: 'x',
      date: DateTime.utc(2026),
      account: 'A',
      toAccount: 'B',
    );

    test('signedAmount depends on the subclass', () {
      expect(income.signedAmount, 10);
      expect(expense.signedAmount, -10);
      expect(transfer.signedAmount, 0);
    });

    test('switch over the sealed class is exhaustive', () {
      String label(Transaction t) => switch (t) {
        Income() => 'in',
        Expense() => 'out',
        Transfer(:final toAccount) => 'to $toAccount',
      };
      expect([income, expense, transfer].map(label), ['in', 'out', 'to B']);
    });

    test('toJson includes the type and toAccount', () {
      expect(income.toJson()['type'], 'income');
      expect(income.toJson()['toAccount'], isNull);
      expect(transfer.toJson()['toAccount'], 'B');
    });
  });

  test('toJson round-trips for every subclass', () {
    for (final t in SampleData.transactions()) {
      expect(Transaction.fromJson(t.toJson()), t, reason: t.id);
    }
  });

  test('copyWith keeps the subclass and can clear optionals', () {
    final t = Transaction.fromJson(expenseJson);
    final copy = t.copyWith(amount: 1, category: () => null);
    expect(copy, isA<Expense>());
    expect(copy.amount, 1);
    expect(copy.category, isNull);
    expect(copy.id, t.id);
  });

  test('equality distinguishes subclasses with the same fields', () {
    final a = Transaction.fromJson(expenseJson);
    final b = Transaction.fromJson({...expenseJson, 'type': 'income'});
    expect(a == b, isFalse);
    expect(a, Transaction.fromJson(expenseJson));
    expect(a.hashCode, Transaction.fromJson(expenseJson).hashCode);
  });
}
