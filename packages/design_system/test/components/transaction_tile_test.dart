import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  group('TransactionTile', () {
    testWidgets('renders title, subtitle, amount and fires onTap', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(
          TransactionTile(
            kind: TransactionKind.expense,
            title: 'Mercado',
            subtitle: 'Alimentação · Nubank',
            amount: 'R\$ 89,90',
            onTap: () => taps++,
          ),
        ),
      );
      expect(find.text('Mercado'), findsOneWidget);
      expect(find.text('Alimentação · Nubank'), findsOneWidget);
      expect(find.text('−R\$ 89,90'), findsOneWidget);
      await tester.tap(find.byType(ListTile));
      expect(taps, 1);
    });

    testWidgets('icon follows kind', (tester) async {
      await tester.pumpWidget(
        wrap(
          const Column(
            children: [
              TransactionTile(
                kind: TransactionKind.income,
                title: 'a',
                amount: '1',
              ),
              TransactionTile(
                kind: TransactionKind.transfer,
                title: 'b',
                amount: '2',
              ),
            ],
          ),
        ),
      );
      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);
    });
  });
}
