import '../models/page.dart';
import '../models/summary.dart';
import '../models/transaction.dart';
import '../models/transaction_filter.dart';
import '../result/result.dart';

/// Transactions of the signed-in user.
abstract interface class TransactionRepository {
  Future<Result<Page<Transaction>>> list(TransactionFilter filter);

  Future<Result<Transaction>> getById(String id);

  /// [transaction.id] is ignored; the repository assigns one.
  Future<Result<Transaction>> create(Transaction transaction);

  Future<Result<Transaction>> update(Transaction transaction);

  Future<Result<void>> delete(String id);

  /// Totals of [month] (`YYYY-MM`).
  Future<Result<Summary>> summary(String month);

  /// Emits the full current list after every successful mutation, so a screen
  /// can react to a delete made elsewhere.
  Stream<List<Transaction>> watch();
}
