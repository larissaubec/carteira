import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  group('MoneyText', () {
    testWidgets('uses semantic colors per tone', (tester) async {
      await tester.pumpWidget(
        wrap(
          const Column(
            children: [
              MoneyText('R\$ 1,00', key: Key('n')),
              MoneyText('R\$ 1,00', key: Key('i'), tone: MoneyTone.income),
              MoneyText('R\$ 1,00', key: Key('e'), tone: MoneyTone.expense),
            ],
          ),
        ),
      );
      Color colorOf(String key) => tester
          .widget<Text>(
            find.descendant(
              of: find.byKey(Key(key)),
              matching: find.byType(Text),
            ),
          )
          .style!
          .color!;
      expect(colorOf('n'), AppColors.light.onSurface);
      expect(colorOf('i'), AppColors.light.income);
      expect(colorOf('e'), AppColors.light.expense);
    });

    testWidgets('signed adds + and − prefixes', (tester) async {
      await tester.pumpWidget(
        wrap(
          const Column(
            children: [
              MoneyText('R\$ 1,00', tone: MoneyTone.income, signed: true),
              MoneyText('R\$ 2,00', tone: MoneyTone.expense, signed: true),
              MoneyText('R\$ 3,00', signed: true),
            ],
          ),
        ),
      );
      expect(find.text('+R\$ 1,00'), findsOneWidget);
      expect(find.text('−R\$ 2,00'), findsOneWidget);
      expect(find.text('R\$ 3,00'), findsOneWidget);
    });
  });
}
