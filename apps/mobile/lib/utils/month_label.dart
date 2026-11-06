const _shortMonths = [
  'jan',
  'fev',
  'mar',
  'abr',
  'mai',
  'jun',
  'jul',
  'ago',
  'set',
  'out',
  'nov',
  'dez',
];

/// `set/2026` from a `YYYY-MM` key, for the month selector chips.
///
/// The long form (`setembro de 2026`) is `formatMonthKey` in carteira_core.
String formatMonthShort(String monthKey) {
  final parts = monthKey.split('-');
  final month = parts.length == 2 ? int.tryParse(parts[1]) : null;
  if (month == null || month < 1 || month > 12) {
    throw FormatException('Invalid month key: $monthKey');
  }
  return '${_shortMonths[month - 1]}/${parts[0]}';
}
