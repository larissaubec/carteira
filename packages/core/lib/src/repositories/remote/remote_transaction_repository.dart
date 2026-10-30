import 'dart:async';

import '../../api/api_client.dart';
import '../../models/json.dart';
import '../../models/page.dart';
import '../../models/summary.dart';
import '../../models/transaction.dart';
import '../../models/transaction_filter.dart';
import '../../result/result.dart';
import '../transaction_repository.dart';

/// Transactions against the API.
class RemoteTransactionRepository implements TransactionRepository {
  RemoteTransactionRepository({required this._client});

  final ApiClient _client;
  final _changes = StreamController<List<Transaction>>.broadcast();

  @override
  Future<Result<Page<Transaction>>> list(TransactionFilter filter) async {
    final result = await _client.get(
      '/transactions',
      query: filter.toQueryParameters(),
    );
    return result.map(
      (json) => Page.fromJson(asJson(json), Transaction.fromJson),
    );
  }

  @override
  Future<Result<Transaction>> getById(String id) async {
    final result = await _client.get('/transactions/$id');
    return result.map((json) => Transaction.fromJson(asJson(json)));
  }

  @override
  Future<Result<Transaction>> create(Transaction transaction) async {
    final body = transaction.toJson()..remove('id');
    final result = await _client.post('/transactions', body: body);
    final created = result.map((json) => Transaction.fromJson(asJson(json)));
    await _notify(created);
    return created;
  }

  @override
  Future<Result<Transaction>> update(Transaction transaction) async {
    final result = await _client.put(
      '/transactions/${transaction.id}',
      body: transaction.toJson(),
    );
    final updated = result.map((json) => Transaction.fromJson(asJson(json)));
    await _notify(updated);
    return updated;
  }

  @override
  Future<Result<void>> delete(String id) async {
    final result = await _client.delete('/transactions/$id');
    final deleted = result.map((_) {});
    await _notify(deleted);
    return deleted;
  }

  @override
  Future<Result<Summary>> summary(String month) async {
    final result = await _client.get('/summary', query: {'month': month});
    return result.map((json) => Summary.fromJson(asJson(json)));
  }

  @override
  Stream<List<Transaction>> watch() => _changes.stream;

  void dispose() => _changes.close();

  /// After a successful mutation, fetches the first page again and emits it.
  Future<void> _notify(Result<Object?> result) async {
    if (result.isFailure || _changes.isClosed || !_changes.hasListener) return;
    final refreshed = await list(const TransactionFilter(pageSize: 100));
    final items = refreshed.valueOrNull?.items;
    if (items != null && !_changes.isClosed) _changes.add(items);
  }
}
