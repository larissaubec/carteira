import 'package:carteira_core/carteira_core.dart';
import 'package:test/test.dart';

void main() {
  test('validateEmail', () {
    expect(validateEmail(null), isNotNull);
    expect(validateEmail(' '), isNotNull);
    expect(validateEmail('ana@'), isNotNull);
    expect(validateEmail('ana@carteira.dev'), isNull);
    expect(validateEmail(' ana.r+x@mail.co.uk '), isNull);
  });

  test('validatePassword', () {
    expect(validatePassword(''), isNotNull);
    expect(validatePassword('123'), contains('6'));
    expect(validatePassword('123456'), isNull);
  });

  test('validateRequired', () {
    expect(validateRequired('  ', field: 'Nome'), 'Nome é obrigatório.');
    expect(validateRequired('Ana'), isNull);
  });

  test('validateAmount and parseAmount accept both notations', () {
    expect(parseAmount('1234.56'), 1234.56);
    expect(parseAmount('1.234,56'), 1234.56);
    expect(parseAmount('12,5'), 12.5);
    expect(parseAmount('abc'), isNull);
    expect(validateAmount('0'), isNotNull);
    expect(validateAmount('-1'), isNotNull);
    expect(validateAmount(''), isNotNull);
    expect(validateAmount('89,90'), isNull);
  });
}
