import 'json.dart';

/// Totals of a month.
class Summary {
  const Summary({
    required this.month,
    required this.income,
    required this.expense,
  });

  factory Summary.fromJson(Json json) => Summary(
    month: json.readString('month'),
    income: json.readDouble('income'),
    expense: json.readDouble('expense'),
  );

  /// `YYYY-MM`.
  final String month;
  final double income;
  final double expense;

  double get balance => income - expense;

  Json toJson() => {
    'month': month,
    'income': income,
    'expense': expense,
    'balance': balance,
  };

  @override
  bool operator ==(Object other) =>
      other is Summary &&
      other.month == month &&
      other.income == income &&
      other.expense == expense;

  @override
  int get hashCode => Object.hash(month, income, expense);

  @override
  String toString() => 'Summary($month, +$income, -$expense)';
}
