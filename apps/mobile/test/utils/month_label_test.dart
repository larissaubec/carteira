import 'package:carteira_app/utils/month_label.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats a month key as short month and year', () {
    expect(formatMonthShort('2026-09'), 'set/2026');
    expect(formatMonthShort('2026-01'), 'jan/2026');
    expect(formatMonthShort('2025-12'), 'dez/2025');
  });

  test('rejects an invalid key', () {
    expect(() => formatMonthShort('2026-13'), throwsFormatException);
    expect(() => formatMonthShort('setembro'), throwsFormatException);
  });
}
