import 'package:carteira_core/carteira_core.dart';
import 'package:test/test.dart';

void main() {
  late InMemoryTransactionRepository repository;

  setUp(() => repository = InMemoryTransactionRepository());

  tearDown(() => repository.dispose());

  group('list', () {
    test('returns newest first', () async {
      final page = (await repository.list(const TransactionFilter()))
          .valueOrNull!;
      final dates = page.items.map((t) => t.date).toList();
      for (var i = 1; i < dates.length; i++) {
        expect(
          dates[i - 1].isAfter(dates[i]) || dates[i - 1] == dates[i],
          isTrue,
        );
      }
      expect(page.total, SampleData.transactions().length);
    });

    test('filters by month, type and query', () async {
      final september = await repository.list(
        const TransactionFilter(month: '2026-09'),
      );
      expect(
        september.valueOrNull!.items.every((t) => t.date.monthKey == '2026-09'),
        isTrue,
      );
      final incomes = await repository.list(
        const TransactionFilter(type: TransactionType.income),
      );
      expect(incomes.valueOrNull!.items.every((t) => t is Income), isTrue);
      final search = await repository.list(
        const TransactionFilter(query: 'MERC'),
      );
      expect(search.valueOrNull!.items.map((t) => t.description), [
        'Mercado',
        'Mercado do mês',
      ]);
    });

    test('paginates', () async {
      final first = (await repository.list(
        const TransactionFilter(pageSize: 5),
      )).valueOrNull!;
      expect(first.items, hasLength(5));
      expect(first.hasMore, isTrue);
      final last = (await repository.list(
        const TransactionFilter(pageSize: 5, page: 3),
      )).valueOrNull!;
      expect(last.items, hasLength(3));
      expect(last.hasMore, isFalse);
      final beyond = (await repository.list(
        const TransactionFilter(pageSize: 5, page: 9),
      )).valueOrNull!;
      expect(beyond.items, isEmpty);
    });

    test('rejects invalid paging', () async {
      final result = await repository.list(const TransactionFilter(page: 0));
      expect(result.errorOrNull, isA<ValidationError>());
    });
  });

  test('getById finds or fails with NotFoundError', () async {
    expect((await repository.getById('tx_0002')).valueOrNull?.id, 'tx_0002');
    expect(
      await repository.getById('tx_nope'),
      const Failure<Transaction>(NotFoundError('tx_nope')),
    );
  });

  test('create assigns an id, validates and emits on watch', () async {
    final emitted = <List<Transaction>>[];
    final sub = repository.watch().listen(emitted.add);
    final created = await repository.create(
      Expense(
        id: '',
        amount: 10,
        description: 'Café',
        date: DateTime.utc(2026, 9, 8),
        account: 'Carteira',
      ),
    );
    expect(created.valueOrNull!.id, startsWith('tx_'));
    await Future<void>.delayed(Duration.zero);
    expect(emitted, hasLength(1));
    expect(emitted.single.first.description, 'Café');
    await sub.cancel();

    final invalid = await repository.create(
      Expense(
        id: '',
        amount: 0,
        description: '',
        date: DateTime.utc(2026),
        account: 'A',
      ),
    );
    final error = invalid.errorOrNull;
    expect(error, isA<ValidationError>());
    expect((error! as ValidationError).fields.keys, ['amount', 'description']);
  });

  test('update replaces an existing item', () async {
    final original = (await repository.getById('tx_0002')).valueOrNull!;
    final updated = await repository.update(original.copyWith(amount: 99));
    expect(updated.valueOrNull!.amount, 99);
    expect((await repository.getById('tx_0002')).valueOrNull!.amount, 99);
    final missing = await repository.update(original.copyWith(id: 'tx_zzz'));
    expect(missing.errorOrNull, isA<NotFoundError>());
  });

  test('delete removes and fails on unknown id', () async {
    expect(await repository.delete('tx_0002'), const Ok<void>(null));
    expect(
      (await repository.getById('tx_0002')).errorOrNull,
      isA<NotFoundError>(),
    );
    expect(
      (await repository.delete('tx_0002')).errorOrNull,
      isA<NotFoundError>(),
    );
  });

  test('summary ignores transfers', () async {
    final summary = (await repository.summary('2026-09')).valueOrNull!;
    expect(summary.income, 8500);
    expect(
      summary.expense,
      closeTo(89.9 + 1850 + 42.5 + 35 + 129.9 + 260, 0.001),
    );
    expect(summary.balance, closeTo(8500 - 2407.3, 0.001));
    final empty = (await repository.summary('2020-01')).valueOrNull!;
    expect(empty.balance, 0);
  });

  test('delay is honoured', () async {
    final slow = InMemoryTransactionRepository(
      delay: const Duration(milliseconds: 20),
    );
    final stopwatch = Stopwatch()..start();
    await slow.getById('tx_0001');
    expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(15));
    slow.dispose();
  });
}
