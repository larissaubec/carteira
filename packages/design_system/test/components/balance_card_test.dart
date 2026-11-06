import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('BalanceCard shows balance, legs and month', (tester) async {
    await tester.pumpWidget(
      wrap(
        const BalanceCard(
          balance: 'R\$ 5.289,55',
          income: 'R\$ 8.500,00',
          expense: 'R\$ 3.210,45',
          monthLabel: 'Setembro 2026',
        ),
      ),
    );
    expect(find.text('R\$ 5.289,55'), findsOneWidget);
    expect(find.text('R\$ 8.500,00'), findsOneWidget);
    expect(find.text('R\$ 3.210,45'), findsOneWidget);
    expect(find.text('Setembro 2026'), findsOneWidget);
    expect(find.text('Entradas'), findsOneWidget);
    expect(find.text('Saídas'), findsOneWidget);
  });
}
