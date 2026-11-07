import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  group('StateView', () {
    testWidgets('loading shows a spinner', (tester) async {
      await tester.pumpWidget(wrap(const StateView.loading()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('empty shows message and optional action', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(
          StateView.empty(
            message: 'Nada por aqui',
            actionLabel: 'Adicionar',
            onAction: () => taps++,
          ),
        ),
      );
      expect(find.text('Nada por aqui'), findsOneWidget);
      await tester.tap(find.text('Adicionar'));
      expect(taps, 1);
    });

    testWidgets('error shows message and retry', (tester) async {
      var retries = 0;
      await tester.pumpWidget(
        wrap(StateView.error(message: 'Falhou', onRetry: () => retries++)),
      );
      expect(find.text('Falhou'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      await tester.tap(find.text('Tentar novamente'));
      expect(retries, 1);
    });
  });
}
