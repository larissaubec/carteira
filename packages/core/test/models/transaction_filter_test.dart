import 'package:carteira_core/carteira_core.dart';
import 'package:test/test.dart';

void main() {
  test('omits null and empty filters from the query', () {
    const filter = TransactionFilter();
    expect(filter.toQueryParameters(), {'page': '1', 'pageSize': '20'});
  });

  test('includes every set filter', () {
    const filter = TransactionFilter(
      month: '2026-09',
      type: TransactionType.expense,
      query: 'merc',
      page: 2,
      pageSize: 5,
    );
    expect(filter.toQueryParameters(), {
      'month': '2026-09',
      'type': 'expense',
      'q': 'merc',
      'page': '2',
      'pageSize': '5',
    });
  });

  test('nextPage increments the page and copyWith can clear', () {
    const filter = TransactionFilter(month: '2026-09');
    expect(filter.nextPage().page, 2);
    expect(filter.copyWith(month: () => null).month, isNull);
  });
}
