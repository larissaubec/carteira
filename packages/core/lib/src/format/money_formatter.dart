import 'package:intl/intl.dart';

import '../models/currency.dart';

/// Formats amounts for display.
///
/// Strategy pattern: one implementation per currency behind a common
/// interface, chosen at runtime by whoever needs to format money.
abstract interface class MoneyFormatter {
  /// Picks the formatter for [currency].
  factory MoneyFormatter.forCurrency(Currency currency) => switch (currency) {
    Currency.brl => const BrlFormatter(),
    Currency.usd => const UsdFormatter(),
    Currency.eur => const EurFormatter(),
  };

  Currency get currency;

  /// `R$ 1.234,56`
  String format(double amount);

  /// `+ R$ 1.234,56`, `- R$ 89,90`, `R$ 0,00`
  String formatSigned(double signedAmount);
}

abstract base class _PatternFormatter implements MoneyFormatter {
  const _PatternFormatter();

  NumberFormat get _format;

  @override
  String format(double amount) => _format.format(amount);

  @override
  String formatSigned(double signedAmount) {
    if (signedAmount == 0) return format(0);
    final sign = signedAmount > 0 ? '+' : '-';
    return '$sign ${format(signedAmount.abs())}';
  }
}

/// `R$ 1.234,56`
final class BrlFormatter extends _PatternFormatter {
  const BrlFormatter();

  @override
  Currency get currency => Currency.brl;

  @override
  NumberFormat get _format =>
      NumberFormat.currency(locale: 'pt_BR', symbol: r'R$', decimalDigits: 2);
}

/// `$1,234.56`
final class UsdFormatter extends _PatternFormatter {
  const UsdFormatter();

  @override
  Currency get currency => Currency.usd;

  @override
  NumberFormat get _format =>
      NumberFormat.currency(locale: 'en_US', symbol: r'$', decimalDigits: 2);
}

/// `1.234,56 €`
final class EurFormatter extends _PatternFormatter {
  const EurFormatter();

  @override
  Currency get currency => Currency.eur;

  @override
  NumberFormat get _format =>
      NumberFormat.currency(locale: 'de_DE', symbol: '€', decimalDigits: 2);
}
