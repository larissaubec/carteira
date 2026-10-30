import 'package:carteira_core/carteira_core.dart';
import 'package:test/test.dart';

void main() {
  test('fromJson parses items with the given parser', () {
    final page = Page.fromJson({
      'items': [SampleData.user.toJson()],
      'page': 1,
      'pageSize': 20,
      'total': 1,
    }, User.fromJson);
    expect(page.items.single, SampleData.user);
    expect(page.hasMore, isFalse);
  });

  test('hasMore uses page, pageSize and total', () {
    const page = Page<int>(items: [1, 2], page: 1, pageSize: 2, total: 5);
    expect(page.hasMore, isTrue);
    const last = Page<int>(items: [5], page: 3, pageSize: 2, total: 5);
    expect(last.hasMore, isFalse);
  });

  test('fromJson falls back when paging fields are missing', () {
    final page = Page.fromJson({'items': <Object?>[]}, User.fromJson);
    expect(page.isEmpty, isTrue);
    expect(page.total, 0);
  });

  test('fromJson rejects a non-list items field', () {
    expect(
      () => Page.fromJson({'items': 'nope'}, User.fromJson),
      throwsFormatException,
    );
  });
}
