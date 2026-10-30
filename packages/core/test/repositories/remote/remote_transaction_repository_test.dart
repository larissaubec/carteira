import 'package:carteira_core/carteira_core.dart';
import 'package:test/test.dart';

import 'fake_server.dart';

void main() {
  late FakeServer server;
  late RemoteTransactionRepository repository;
  final sample = SampleData.transactions();

  Map<String, Object?> pageJson(List<Transaction> items) => {
    'items': [for (final t in items) t.toJson()],
    'page': 1,
    'pageSize': 20,
    'total': items.length,
  };

  setUp(() {
    server = FakeServer();
    repository = RemoteTransactionRepository(
      client: ApiClient(
        baseUrl: 'http://localhost:8080',
        client: server.client,
      ),
    );
  });

  tearDown(() => repository.dispose());

  test('list sends the filter as query and parses the page', () async {
    server.on('GET', '/transactions', 200, pageJson(sample.take(3).toList()));
    final result = await repository.list(
      const TransactionFilter(month: '2026-09', type: TransactionType.expense),
    );
    expect(result.valueOrNull?.items, sample.take(3).toList());
    expect(server.last.url.queryParameters, {
      'month': '2026-09',
      'type': 'expense',
      'page': '1',
      'pageSize': '20',
    });
  });

  test('getById parses one transaction and maps 404', () async {
    server.on('GET', '/transactions/tx_0002', 200, sample[1].toJson());
    expect(await repository.getById('tx_0002'), Ok<Transaction>(sample[1]));
    expect(
      (await repository.getById('tx_zzz')).errorOrNull,
      isA<NotFoundError>(),
    );
  });

  test('create posts without id and returns the created item', () async {
    final created = sample[1].copyWith(id: 'tx_new');
    server.on('POST', '/transactions', 201, created.toJson());
    final result = await repository.create(sample[1]);
    expect(result, Ok<Transaction>(created));
    expect(server.lastBody.containsKey('id'), isFalse);
    expect(server.lastBody['type'], 'expense');
  });

  test('update puts the full JSON', () async {
    final updated = sample[1].copyWith(amount: 1);
    server.on('PUT', '/transactions/tx_0002', 200, updated.toJson());
    expect(await repository.update(updated), Ok<Transaction>(updated));
    expect(server.lastBody['amount'], 1);
  });

  test('delete returns Ok on 204 and NotFound on 404', () async {
    server.on('DELETE', '/transactions/tx_0002', 204);
    expect(await repository.delete('tx_0002'), const Ok<void>(null));
    expect(
      (await repository.delete('tx_zzz')).errorOrNull,
      isA<NotFoundError>(),
    );
  });

  test('summary parses totals', () async {
    server.on('GET', '/summary', 200, {
      'month': '2026-09',
      'income': 8500,
      'expense': 2407.3,
      'balance': 6092.7,
    });
    final summary = (await repository.summary('2026-09')).valueOrNull!;
    expect(summary.balance, closeTo(6092.7, 0.001));
    expect(server.last.url.queryParameters['month'], '2026-09');
  });

  test('watch emits a refreshed list after a successful mutation', () async {
    server.on('DELETE', '/transactions/tx_0002', 204);
    server.on('GET', '/transactions', 200, pageJson(sample.skip(2).toList()));
    final emitted = <List<Transaction>>[];
    final sub = repository.watch().listen(emitted.add);
    await repository.delete('tx_0002');
    await Future<void>.delayed(Duration.zero);
    expect(emitted.single, sample.skip(2).toList());
    await sub.cancel();
  });

  test('watch does not emit after a failed mutation', () async {
    final emitted = <List<Transaction>>[];
    final sub = repository.watch().listen(emitted.add);
    await repository.delete('tx_zzz');
    await Future<void>.delayed(Duration.zero);
    expect(emitted, isEmpty);
    await sub.cancel();
  });
}
