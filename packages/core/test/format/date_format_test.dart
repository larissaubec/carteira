import 'package:carteira_core/carteira_core.dart';
import 'package:test/test.dart';

void main() {
  final date = DateTime(2026, 9, 6, 14, 32);

  test('formatDate and formatDateTime use pt_BR order', () {
    expect(formatDate(date), '06/09/2026');
    expect(formatDateTime(date), '06/09/2026 14:32');
  });

  test('formatMonthKey spells the month', () {
    expect(formatMonthKey('2026-09'), 'setembro de 2026');
    expect(() => formatMonthKey('2026'), throwsFormatException);
    expect(() => formatMonthKey('2026-13'), throwsFormatException);
  });

  test('formatDayHeading spells weekday and day', () {
    expect(formatDayHeading(date), 'domingo, 6 de setembro');
  });
}
