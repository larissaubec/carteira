/// Small helpers used all over the app.
extension DateTimeX on DateTime {
  /// `2026-09` for grouping and filtering by month.
  String get monthKey {
    final local = toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}';
  }

  /// Same calendar day in local time.
  bool sameDay(DateTime other) {
    final a = toLocal();
    final b = other.toLocal();
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Midnight of this day, local time.
  DateTime get dayStart {
    final local = toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
