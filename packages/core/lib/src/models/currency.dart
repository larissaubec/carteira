/// Currencies the app can display amounts in.
enum Currency {
  brl('BRL', r'R$'),
  usd('USD', r'$'),
  eur('EUR', '€');

  const Currency(this.code, this.symbol);

  final String code;
  final String symbol;

  static Currency fromJson(String value) => Currency.values.firstWhere(
    (currency) => currency.code == value.toUpperCase(),
    orElse: () => throw FormatException('Unknown currency: $value'),
  );

  String toJson() => code;
}
