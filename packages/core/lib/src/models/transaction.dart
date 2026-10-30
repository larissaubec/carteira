import 'json.dart';
import 'transaction_type.dart';

/// A money movement.
///
/// This is a sealed hierarchy: every transaction is exactly one of [Income],
/// [Expense] or [Transfer], and a `switch` over a [Transaction] must handle all
/// three. The subclasses live in this file because Dart requires the members of
/// a sealed class to be declared in the same library.
sealed class Transaction {
  const Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.account,
    this.category,
    this.note,
  });

  /// Builds the right subclass from the `type` field.
  factory Transaction.fromJson(Json json) {
    final type = TransactionType.fromJson(json.readString('type'));
    return switch (type) {
      TransactionType.income => Income.fromJson(json),
      TransactionType.expense => Expense.fromJson(json),
      TransactionType.transfer => Transfer.fromJson(json),
    };
  }

  final String id;

  /// Always positive. Use [signedAmount] to know the direction.
  final double amount;
  final String description;
  final DateTime date;
  final String account;

  /// Optional: the user may not classify every transaction.
  final String? category;

  /// Optional free text.
  final String? note;

  TransactionType get type;

  /// Effect on the balance: positive for income, negative for expense and
  /// zero for a transfer between the user's own accounts.
  double get signedAmount;

  Json toJson() => {
    'id': id,
    'type': type.toJson(),
    'amount': amount,
    'description': description,
    'category': category,
    'date': date.toUtc().toIso8601String(),
    'note': note,
    'account': account,
    'toAccount': null,
  };

  Transaction copyWith({
    String? id,
    double? amount,
    String? description,
    DateTime? date,
    String? account,
    String? Function()? category,
    String? Function()? note,
  });

  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType &&
      other is Transaction &&
      other.id == id &&
      other.amount == amount &&
      other.description == description &&
      other.date == date &&
      other.account == account &&
      other.category == category &&
      other.note == note;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    amount,
    description,
    date,
    account,
    category,
    note,
  );

  @override
  String toString() => '${type.name}($id, $description, $amount)';
}

/// Money coming in.
final class Income extends Transaction {
  const Income({
    required super.id,
    required super.amount,
    required super.description,
    required super.date,
    required super.account,
    super.category,
    super.note,
  });

  factory Income.fromJson(Json json) => Income(
    id: json.readString('id'),
    amount: json.readDouble('amount'),
    description: json.readString('description'),
    date: json.readDateTime('date'),
    account: json.readString('account'),
    category: json.readOptionalString('category'),
    note: json.readOptionalString('note'),
  );

  @override
  TransactionType get type => TransactionType.income;

  @override
  double get signedAmount => amount;

  @override
  Income copyWith({
    String? id,
    double? amount,
    String? description,
    DateTime? date,
    String? account,
    String? Function()? category,
    String? Function()? note,
  }) => Income(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    description: description ?? this.description,
    date: date ?? this.date,
    account: account ?? this.account,
    category: category != null ? category() : this.category,
    note: note != null ? note() : this.note,
  );
}

/// Money going out.
final class Expense extends Transaction {
  const Expense({
    required super.id,
    required super.amount,
    required super.description,
    required super.date,
    required super.account,
    super.category,
    super.note,
  });

  factory Expense.fromJson(Json json) => Expense(
    id: json.readString('id'),
    amount: json.readDouble('amount'),
    description: json.readString('description'),
    date: json.readDateTime('date'),
    account: json.readString('account'),
    category: json.readOptionalString('category'),
    note: json.readOptionalString('note'),
  );

  @override
  TransactionType get type => TransactionType.expense;

  @override
  double get signedAmount => -amount;

  @override
  Expense copyWith({
    String? id,
    double? amount,
    String? description,
    DateTime? date,
    String? account,
    String? Function()? category,
    String? Function()? note,
  }) => Expense(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    description: description ?? this.description,
    date: date ?? this.date,
    account: account ?? this.account,
    category: category != null ? category() : this.category,
    note: note != null ? note() : this.note,
  );
}

/// Money moved between two of the user's own accounts.
final class Transfer extends Transaction {
  const Transfer({
    required super.id,
    required super.amount,
    required super.description,
    required super.date,
    required super.account,
    required this.toAccount,
    super.category,
    super.note,
  });

  factory Transfer.fromJson(Json json) => Transfer(
    id: json.readString('id'),
    amount: json.readDouble('amount'),
    description: json.readString('description'),
    date: json.readDateTime('date'),
    account: json.readString('account'),
    toAccount: json.readString('toAccount'),
    category: json.readOptionalString('category'),
    note: json.readOptionalString('note'),
  );

  final String toAccount;

  @override
  TransactionType get type => TransactionType.transfer;

  @override
  double get signedAmount => 0;

  @override
  Json toJson() => super.toJson()..['toAccount'] = toAccount;

  @override
  Transfer copyWith({
    String? id,
    double? amount,
    String? description,
    DateTime? date,
    String? account,
    String? toAccount,
    String? Function()? category,
    String? Function()? note,
  }) => Transfer(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    description: description ?? this.description,
    date: date ?? this.date,
    account: account ?? this.account,
    toAccount: toAccount ?? this.toAccount,
    category: category != null ? category() : this.category,
    note: note != null ? note() : this.note,
  );

  @override
  bool operator ==(Object other) =>
      super == other && other is Transfer && other.toAccount == toAccount;

  @override
  int get hashCode => Object.hash(super.hashCode, toAccount);
}
