import 'package:carteira_core/carteira_core.dart';
import 'package:test/test.dart';

void main() {
  test('parses each item with the given parser', () {
    final users = parseList([
      SampleData.user.toJson(),
      SampleData.user.toJson(),
    ], User.fromJson);
    expect(users, hasLength(2));
    expect(users.first, SampleData.user);
  });

  test('null becomes an empty list', () {
    expect(parseList(null, User.fromJson), isEmpty);
  });

  test('non-list input throws', () {
    expect(() => parseList('x', User.fromJson), throwsFormatException);
  });
}
