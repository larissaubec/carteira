import 'package:carteira_app/features/home/view_model/home_view_model.dart';
import 'package:carteira_core/carteira_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/flush.dart';

void main() {
  late InMemoryAuthRepository auth;

  setUp(() async {
    auth = InMemoryAuthRepository(storage: InMemorySessionStorage());
    await auth.login(email: 'ana@carteira.dev', password: '123456');
  });

  HomeViewModel build({TransactionRepository? transactions}) => HomeViewModel(
    transactionRepository: transactions ?? InMemoryTransactionRepository(),
    authRepository: auth,
    clock: () => DateTime(2026, 10, 23),
    searchDelay: Duration.zero,
  );

  group('months', () {
    test('offers the last 12 months, newest first', () {
      final viewModel = build();
      expect(viewModel.months.first, '2026-10');
      expect(viewModel.months[1], '2026-09');
      expect(viewModel.months.last, '2025-11');
      expect(viewModel.months, hasLength(12));
    });

    test('opens on the month of the newest transaction', () async {
      final viewModel = build();
      await viewModel.load.execute();
      // The sample data ends in September, not in the current October.
      expect(viewModel.selectedMonth, '2026-09');
    });

    test('opens on the current month when there are no transactions', () async {
      final viewModel = build(
        transactions: InMemoryTransactionRepository(transactions: []),
      );
      await viewModel.load.execute();
      expect(viewModel.selectedMonth, '2026-10');
      expect(viewModel.transactions, isEmpty);
      expect(viewModel.categories, isEmpty);
    });
  });

  group('overview', () {
    test('loads the summary of the month', () async {
      final viewModel = build();
      await viewModel.load.execute();

      final summary = viewModel.summary!;
      expect(summary.month, '2026-09');
      expect(summary.income, 8500);
      expect(summary.expense, closeTo(2407.3, 0.001));
      expect(summary.balance, closeTo(6092.7, 0.001));
    });

    test('groups the expenses by category, biggest first', () async {
      final viewModel = build();
      await viewModel.load.execute();

      final categories = viewModel.categories;
      expect(categories.map((c) => c.category), [
        'Moradia',
        'Lazer',
        'Educação',
        'Alimentação',
        'Transporte',
        null, // "Padaria" has no category
      ]);
      expect(categories.first.amount, 1850);
      expect(categories.first.share, closeTo(1850 / 2407.3, 0.0001));
      final totalShare = categories.fold<double>(0, (s, c) => s + c.share);
      expect(totalShare, closeTo(1, 0.0001));
    });

    test('byCategory returns nothing for a month without expenses', () {
      expect(HomeViewModel.byCategory(const []), isEmpty);
    });

    test('changing the month reloads everything', () async {
      final viewModel = build();
      await viewModel.load.execute();

      viewModel.selectMonth('2026-08');
      expect(viewModel.summary, isNull, reason: 'old month is dropped');
      await flush();

      expect(viewModel.selectedMonth, '2026-08');
      expect(viewModel.summary?.income, 9700);
      expect(viewModel.transactions, hasLength(5));
      expect(viewModel.categories.first.category, 'Moradia');
    });
  });

  group('list', () {
    test('loads the transactions of the month, grouped by day', () async {
      final viewModel = build();
      await viewModel.load.execute();

      expect(viewModel.transactions, hasLength(8));
      final sections = viewModel.sections;
      expect(sections.expand((s) => s.items), hasLength(8));
      for (var i = 1; i < sections.length; i++) {
        expect(sections[i].day.isBefore(sections[i - 1].day), isTrue);
      }
      expect(viewModel.hasMore, isFalse);
    });

    test('filters by type without touching the overview', () async {
      final viewModel = build();
      await viewModel.load.execute();
      final summary = viewModel.summary;

      viewModel.selectType(TransactionType.income);
      await flush();

      expect(viewModel.transactions, hasLength(1));
      expect(viewModel.transactions.single, isA<Income>());
      expect(viewModel.summary, same(summary));
    });

    test('searches by description', () async {
      final viewModel = build();
      await viewModel.load.execute();

      viewModel.search('merc');
      await flush();

      expect(viewModel.transactions.map((t) => t.description), ['Mercado']);
    });

    test('pages through the list', () async {
      final viewModel = HomeViewModel(
        transactionRepository: InMemoryTransactionRepository(),
        authRepository: auth,
        clock: () => DateTime(2026, 10, 23),
        pageSize: 3,
      );
      await viewModel.load.execute();
      expect(viewModel.transactions, hasLength(3));
      expect(viewModel.hasMore, isTrue);

      await viewModel.loadMore.execute();
      await viewModel.loadMore.execute();
      expect(viewModel.transactions, hasLength(8));
      expect(viewModel.hasMore, isFalse);
      // Categories still cover the whole month, not just the loaded page.
      expect(viewModel.categories, hasLength(6));
    });
  });

  group('errors', () {
    test('a failed load is exposed on the command', () async {
      final viewModel = build(
        transactions: FailingTransactionRepository(const NetworkError()),
      );
      await viewModel.load.execute();

      expect(viewModel.load.error, isTrue);
      expect(viewModel.load.result?.errorOrNull, const NetworkError());
      expect(viewModel.sessionExpired, isFalse);
      expect(auth.currentSession, isNotNull);
    });

    test('a 401 clears the session and asks for login', () async {
      final viewModel = build(
        transactions: FailingTransactionRepository(
          const UnauthorizedError(expired: true),
        ),
      );
      await viewModel.load.execute();

      expect(viewModel.sessionExpired, isTrue);
      expect(auth.currentSession, isNull);
    });
  });

}
