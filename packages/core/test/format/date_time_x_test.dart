import 'package:carteira_core/carteira_core.dart';
import 'package:test/test.dart';

void main() {
  test('monthKey pads the month', () {
    expect(DateTime(2026, 9, 6).monthKey, '2026-09');
    expect(DateTime(2026, 12, 31).monthKey, '2026-12');
  });

  test('sameDay compares calendar days', () {
    final a = DateTime(2026, 9, 6, 1);
    final b = DateTime(2026, 9, 6, 23);
    expect(a.sameDay(b), isTrue);
    expect(a.sameDay(DateTime(2026, 9, 7)), isFalse);
  });

  test('dayStart is midnight', () {
    expect(DateTime(2026, 9, 6, 15, 30).dayStart, DateTime(2026, 9, 6));
  });
}
