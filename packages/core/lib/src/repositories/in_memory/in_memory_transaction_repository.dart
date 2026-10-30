import 'dart:async';

import '../../format/date_time_x.dart';
import '../../models/page.dart';
import '../../models/summary.dart';
import '../../models/transaction.dart';
import '../../models/transaction_filter.dart';
import '../../result/app_error.dart';
import '../../result/result.dart';
import '../transaction_repository.dart';
import 'sample_data.dart';

/// Stores transactions in a list. Behaves like the server: same filters,
/// same ordering, same validation, same errors.
class InMemoryTransactionRepository implements TransactionRepository {
  InMemoryTransactionRepository({
    List<Transaction>? transactions,
    this.delay = Duration.zero,
  }) : _items = [...transactions ?? SampleData.transactions()];

  final List<Transaction> _items;
  final Duration delay;
  final _changes = StreamController<List<Transaction>>.broadcast();
  int _nextId = 1000;

  /// Current items, newest first. Handy for tests.
  List<Transaction> get items => _sorted(_items);

  @override
  Future<Result<Page<Transaction>>> list(TransactionFilter filter) async {
    await Future<void>.delayed(delay);
    if (filter.page < 1 || filter.pageSize < 1) {
      return const Failure(
        ValidationError({'page': 'must be greater than zero'}),
      );
    }
    final query = filter.query?.toLowerCase();
    final filtered = _sorted(_items).where((t) {
      if (filter.month != null && t.date.monthKey != filter.month) return false;
      if (filter.type != null && t.type != filter.type) return false;
      if (query != null && query.isNotEmpty) {
        return t.description.toLowerCase().contains(query);
      }
      return true;
    }).toList();
    final start = (filter.page - 1) * filter.pageSize;
    final items = start >= filtered.length
        ? <Transaction>[]
        : filtered.sublist(
            start,
            (start + filter.pageSize).clamp(0, filtered.length),
          );
    return Ok(
      Page(
        items: items,
        page: filter.page,
        pageSize: filter.pageSize,
        total: filtered.length,
      ),
    );
  }

  @override
  Future<Result<Transaction>> getById(String id) async {
    await Future<void>.delayed(delay);
    final found = _find(id);
    return found == null ? Failure(NotFoundError(id)) : Ok(found);
  }

  @override
  Future<Result<Transaction>> create(Transaction transaction) async {
    await Future<void>.delayed(delay);
    final error = _validate(transaction);
    if (error != null) return Failure(error);
    final created = transaction.copyWith(id: 'tx_${_nextId++}');
    _items.add(created);
    _emit();
    return Ok(created);
  }

  @override
  Future<Result<Transaction>> update(Transaction transaction) async {
    await Future<void>.delayed(delay);
    final index = _items.indexWhere((t) => t.id == transaction.id);
    if (index < 0) return Failure(NotFoundError(transaction.id));
    final error = _validate(transaction);
    if (error != null) return Failure(error);
    _items[index] = transaction;
    _emit();
    return Ok(transaction);
  }

  @override
  Future<Result<void>> delete(String id) async {
    await Future<void>.delayed(delay);
    final index = _items.indexWhere((t) => t.id == id);
    if (index < 0) return Failure(NotFoundError(id));
    _items.removeAt(index);
    _emit();
    return const Ok(null);
  }

  @override
  Future<Result<Summary>> summary(String month) async {
    await Future<void>.delayed(delay);
    var income = 0.0;
    var expense = 0.0;
    for (final t in _items.where((t) => t.date.monthKey == month)) {
      switch (t) {
        case Income():
          income += t.amount;
        case Expense():
          expense += t.amount;
        case Transfer():
          break;
      }
    }
    return Ok(Summary(month: month, income: income, expense: expense));
  }

  @override
  Stream<List<Transaction>> watch() => _changes.stream;

  void dispose() => _changes.close();

  Transaction? _find(String id) {
    for (final t in _items) {
      if (t.id == id) return t;
    }
    return null;
  }

  void _emit() {
    if (!_changes.isClosed) _changes.add(items);
  }

  static List<Transaction> _sorted(List<Transaction> items) =>
      [...items]..sort((a, b) => b.date.compareTo(a.date));

  static AppError? _validate(Transaction t) {
    final fields = <String, String>{
      if (t.amount <= 0) 'amount': 'must be greater than zero',
      if (t.description.trim().isEmpty) 'description': 'must not be empty',
      if (t.account.trim().isEmpty) 'account': 'must not be empty',
      if (t is Transfer && t.toAccount.trim().isEmpty)
        'toAccount': 'required for transfers',
    };
    return fields.isEmpty ? null : ValidationError(fields);
  }
}
