import 'package:intl/intl.dart';

const _monthNames = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];

const _weekdayNames = [
  'segunda-feira',
  'terça-feira',
  'quarta-feira',
  'quinta-feira',
  'sexta-feira',
  'sábado',
  'domingo',
];

/// `06/09/2026`
String formatDate(DateTime date) =>
    DateFormat('dd/MM/yyyy').format(date.toLocal());

/// `06/09/2026 14:32`
String formatDateTime(DateTime date) =>
    DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal());

/// `setembro de 2026` from a `YYYY-MM` key.
String formatMonthKey(String monthKey) {
  final parts = monthKey.split('-');
  if (parts.length != 2) throw FormatException('Invalid month key: $monthKey');
  final year = parts[0];
  final month = int.parse(parts[1]);
  if (month < 1 || month > 12) {
    throw FormatException('Invalid month key: $monthKey');
  }
  return '${_monthNames[month - 1]} de $year';
}

/// `domingo, 6 de setembro`
String formatDayHeading(DateTime date) {
  final local = date.toLocal();
  return '${_weekdayNames[local.weekday - 1]}, ${local.day} de '
      '${_monthNames[local.month - 1]}';
}
