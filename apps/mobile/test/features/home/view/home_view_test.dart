import 'package:carteira_app/features/home/view/home_view.dart';
import 'package:carteira_app/features/home/view_model/home_view_model.dart';
import 'package:carteira_app/routing/routes.dart';
import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/fakes.dart';

void main() {
  late InMemoryAuthRepository auth;

  setUp(() async {
    auth = InMemoryAuthRepository(storage: InMemorySessionStorage());
    await auth.login(email: 'ana@carteira.dev', password: '123456');
  });

  /// [HomeView] inside a router, so `context.go` works.
  Future<void> pumpHome(
      WidgetTester tester,
      TransactionRepository transactions,
      ) async {
    final viewModel = HomeViewModel(
      transactionRepository: transactions,
      authRepository: auth,
      clock: () => DateTime(2026, 10, 23),
    );
    final router = GoRouter(
      initialLocation: Routes.home,
      routes: [
        GoRoute(
          path: Routes.home,
          builder: (_, _) => HomeView(
            viewModel: viewModel,
            themeMode: ValueNotifier(ThemeMode.light),
          ),
        ),
        GoRoute(
          path: Routes.login,
          builder: (_, _) => const Scaffold(body: Text('login')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('uses the design system components with the month data', (
      tester,
      ) async {
    await pumpHome(tester, InMemoryTransactionRepository());

    // Month selector opens on the newest month with data.
    final september = tester.widget<ChoiceChip>(
      find.byKey(const ValueKey('month_2026-09')),
    );
    expect(september.selected, isTrue);

    // Balance card with the formatted totals.
    expect(find.byType(BalanceCard), findsOneWidget);
    expect(find.text('setembro de 2026'), findsOneWidget);
    final money = MoneyFormatter.forCurrency(Currency.brl);
    expect(find.text(money.format(6092.7)), findsOneWidget);

    // One bar per expense category.
    expect(find.byType(CategoryBar), findsNWidgets(6));
    expect(find.text('Moradia'), findsOneWidget);

    // Search and type filter, further down the page.
    await tester.scrollUntilVisible(
      find.byKey(const Key('home_search')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Transf.'), findsOneWidget);
  });

  testWidgets('lists the transactions as tiles grouped by day', (
      tester,
      ) async {
    await pumpHome(tester, InMemoryTransactionRepository());

    await tester.scrollUntilVisible(
      find.text('Aluguel'),
      300,
      // The page list, not the horizontal month selector inside it.
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(TransactionTile), findsWidgets);
    expect(find.byType(SectionHeader), findsWidgets);
    expect(find.text('Moradia · Itaú'), findsOneWidget);
  });

  testWidgets('shows a retry when the first load fails', (tester) async {
    await pumpHome(
      tester,
      FailingTransactionRepository(const ServerError(500)),
    );

    expect(find.byType(StateView), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('an expired session sends the user to login', (tester) async {
    await pumpHome(
      tester,
      FailingTransactionRepository(const UnauthorizedError(expired: true)),
    );

    expect(find.text('login'), findsOneWidget);
    expect(auth.currentSession, isNull);
  });
}