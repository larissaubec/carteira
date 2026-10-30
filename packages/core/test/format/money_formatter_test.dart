import 'package:carteira_core/carteira_core.dart';
import 'package:test/test.dart';

void main() {
  test('forCurrency picks the strategy', () {
    expect(MoneyFormatter.forCurrency(Currency.brl), isA<BrlFormatter>());
    expect(MoneyFormatter.forCurrency(Currency.usd), isA<UsdFormatter>());
    expect(MoneyFormatter.forCurrency(Currency.eur), isA<EurFormatter>());
  });

  test('formats BRL with Brazilian separators', () {
    final f = MoneyFormatter.forCurrency(Currency.brl);
    expect(f.format(1234.56), 'R\$ 1.234,56');
    expect(f.format(0), 'R\$ 0,00');
  });

  test('formats USD and EUR', () {
    expect(
      MoneyFormatter.forCurrency(Currency.usd).format(1234.5),
      r'$1,234.50',
    );
    expect(
      MoneyFormatter.forCurrency(Currency.eur).format(1234.5),
      '1.234,50 €',
    );
  });

  test('formatSigned prefixes the sign', () {
    final f = MoneyFormatter.forCurrency(Currency.brl);
    expect(f.formatSigned(10), startsWith('+ '));
    expect(f.formatSigned(-10), startsWith('- '));
    expect(f.formatSigned(0), f.format(0));
  });
}
