import 'package:carteira_server/src/validation.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  group('validateTransaction', () {
    test('accepts a valid expense', () {
      expect(validateTransaction(sampleTransaction()), isEmpty);
    });

    test('rejects zero amount, empty description and bad date', () {
      final errors = validateTransaction({
        ...sampleTransaction(),
        'amount': 0,
        'description': '  ',
        'date': 'ontem',
      });
      expect(errors.keys, containsAll(['amount', 'description', 'date']));
    });

    test('requires toAccount for transfers', () {
      final errors = validateTransaction({
        ...sampleTransaction(type: 'transfer'),
        'toAccount': null,
      });
      expect(errors, {'toAccount': 'is required for transfers'});
    });

    test('rejects unknown type', () {
      expect(
        validateTransaction({...sampleTransaction(), 'type': 'refund'}),
        containsPair('type', contains('income, expense, transfer')),
      );
    });
  });

  group('normalizeTransaction', () {
    test('rounds amount, trims strings and normalizes the date', () {
      final result = normalizeTransaction({
        ...sampleTransaction(),
        'amount': 10.129,
        'description': '  Café  ',
        'category': '',
        'date': '2026-09-07T13:00:00.000-03:00',
      }, id: 'tx_0001');
      expect(result['amount'], 10.13);
      expect(result['description'], 'Café');
      expect(result['category'], isNull);
      expect(result['date'], '2026-09-07T16:00:00Z');
      expect(result['toAccount'], isNull);
    });
  });

  test('validateProfile requires a name', () {
    expect(validateProfile({'name': 'Ana'}), isEmpty);
    expect(validateProfile({'name': ''}), contains('name'));
  });

  test('validateListQuery checks month, type, page and pageSize', () {
    expect(validateListQuery({'month': '2026-09', 'page': '2'}), isEmpty);
    expect(validateListQuery({'month': '2026-13'}), contains('month'));
    expect(validateListQuery({'type': 'refund'}), contains('type'));
    expect(validateListQuery({'page': '0'}), contains('page'));
    expect(validateListQuery({'pageSize': '500'}), contains('pageSize'));
  });
}
