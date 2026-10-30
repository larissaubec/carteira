import 'package:carteira_core/carteira_core.dart';
import 'package:test/test.dart';

void main() {
  final json = <String, Object?>{
    'text': 'a',
    'empty': '',
    'number': 1,
    'flag': true,
    'when': '2026-09-06T14:32:00Z',
    'nested': {'x': 1},
  };

  test('readers convert and validate types', () {
    expect(json.readString('text'), 'a');
    expect(json.readOptionalString('empty'), isNull);
    expect(json.readOptionalString('missing'), isNull);
    expect(json.readDouble('number'), 1.0);
    expect(json.readInt('number'), 1);
    expect(json.readInt('missing', fallback: 7), 7);
    expect(json.readBool('flag'), isTrue);
    expect(json.readBool('missing', fallback: false), isFalse);
    expect(json.readDateTime('when').isUtc, isTrue);
    expect(json.readObject('nested'), {'x': 1});
  });

  test('readers throw FormatException on wrong types', () {
    expect(() => json.readString('number'), throwsFormatException);
    expect(() => json.readDouble('text'), throwsFormatException);
    expect(() => json.readDateTime('text'), throwsFormatException);
    expect(() => json.readObject('text'), throwsFormatException);
    expect(() => json.readBool('text'), throwsFormatException);
  });

  test('asJson accepts untyped maps', () {
    final untyped = <Object?, Object?>{'a': 1};
    expect(asJson(untyped), {'a': 1});
    expect(() => asJson('x'), throwsFormatException);
  });
}
