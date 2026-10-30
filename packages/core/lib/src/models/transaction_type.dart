/// Kind of a transaction. The string values match the API contract.
enum TransactionType {
  income,
  expense,
  transfer;

  static TransactionType fromJson(String value) =>
      TransactionType.values.firstWhere(
        (type) => type.name == value.toLowerCase(),
        orElse: () => throw FormatException('Unknown transaction type: $value'),
      );

  String toJson() => name;
}
