import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  group('CategoryBar', () {
    testWidgets('shows label, amount and rounded percentage', (tester) async {
      await tester.pumpWidget(
        wrap(
          const CategoryBar(
            label: 'Alimentação',
            amount: 'R\$ 702,20',
            share: 0.378,
          ),
        ),
      );
      expect(find.text('Alimentação'), findsOneWidget);
      expect(find.text('R\$ 702,20'), findsOneWidget);
      expect(find.text('38%'), findsOneWidget);
      final bar = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(bar.widthFactor, 0.378);
    });

    testWidgets('clamps the share to the bar', (tester) async {
      await tester.pumpWidget(
        wrap(const CategoryBar(label: 'Lazer', amount: 'R\$ 1', share: 1.4)),
      );
      final bar = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(bar.widthFactor, 1);
      expect(find.text('100%'), findsOneWidget);
    });
  });
}
