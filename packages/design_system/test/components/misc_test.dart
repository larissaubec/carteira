import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('Gap sizes follow the spacing scale', (tester) async {
    await tester.pumpWidget(wrap(const Gap.lg()));
    final box = tester.getSize(find.byType(Gap));
    expect(box.width, AppSpacing.lg);
    expect(box.height, AppSpacing.lg);
  });

  testWidgets('SectionHeader uppercases title and fires action', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(
        SectionHeader(
          title: 'Hoje',
          actionLabel: 'Ver todos',
          onAction: () => taps++,
        ),
      ),
    );
    expect(find.text('HOJE'), findsOneWidget);
    await tester.tap(find.text('Ver todos'));
    expect(taps, 1);
  });

  testWidgets('AppScaffold renders title, body and bottom', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const AppScaffold(
          title: 'Carteira',
          body: Text('corpo'),
          bottom: SizedBox(height: 40, child: Text('rodapé')),
        ),
      ),
    );
    expect(find.text('Carteira'), findsOneWidget);
    expect(find.text('corpo'), findsOneWidget);
    expect(find.text('rodapé'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('components build in dark theme too', (tester) async {
    await tester.pumpWidget(
      wrap(
        dark: true,
        const Column(
          children: [
            BalanceCard(balance: '1', income: '2', expense: '3'),
            TransactionTile(
              kind: TransactionKind.income,
              title: 't',
              amount: '1',
            ),
          ],
        ),
      ),
    );
    expect(find.byType(BalanceCard), findsOneWidget);
  });
}
