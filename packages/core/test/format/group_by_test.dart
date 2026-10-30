import 'package:carteira_core/carteira_core.dart';
import 'package:test/test.dart';

void main() {
  test('groups preserving first-appearance order', () {
    final groups = groupBy([1, 2, 3, 4, 5], (n) => n.isEven ? 'even' : 'odd');
    expect(groups.keys.toList(), ['odd', 'even']);
    expect(groups['odd'], [1, 3, 5]);
    expect(groups['even'], [2, 4]);
  });

  test('groups transactions by day', () {
    final byDay = groupBy(
      SampleData.transactions(),
      (t) => t.date.toLocal().dayStart,
    );
    expect(byDay.values.every((list) => list.isNotEmpty), isTrue);
    expect(byDay.length, lessThan(SampleData.transactions().length));
  });
}
