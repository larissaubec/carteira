import 'package:carteira_core/carteira_core.dart';

/// A [TransactionRepository] whose every call fails with [error], e.g. a
/// 401 after the server restarted and forgot the token.
class FailingTransactionRepository implements TransactionRepository {
  FailingTransactionRepository(this.error);

  final AppError error;

  @override
  Future<Result<Page<Transaction>>> list(TransactionFilter filter) async =>
      Failure(error);

  @override
  Future<Result<Transaction>> getById(String id) async => Failure(error);

  @override
  Future<Result<Transaction>> create(Transaction transaction) async =>
      Failure(error);

  @override
  Future<Result<Transaction>> update(Transaction transaction) async =>
      Failure(error);

  @override
  Future<Result<void>> delete(String id) async => Failure(error);

  @override
  Future<Result<Summary>> summary(String month) async => Failure(error);

  @override
  Stream<List<Transaction>> watch() => const Stream.empty();
}

/// The session the in-memory repositories accept.
final sampleSession = Session(token: 'tok_test', user: SampleData.user);
