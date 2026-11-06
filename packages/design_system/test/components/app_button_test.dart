import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  group('AppButton', () {
    testWidgets('renders label and calls onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(AppButton(label: 'Entrar', onPressed: () => taps++)),
      );
      expect(find.text('Entrar'), findsOneWidget);
      await tester.tap(find.text('Entrar'));
      expect(taps, 1);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        wrap(const AppButton(label: 'Entrar', onPressed: null)),
      );
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.enabled, isFalse);
    });

    testWidgets('loading state shows spinner and ignores taps', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(
          AppButton(label: 'Entrar', isLoading: true, onPressed: () => taps++),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Entrar'), findsNothing);
      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      expect(taps, 0);
    });

    testWidgets('variants map to Material buttons', (tester) async {
      await tester.pumpWidget(
        wrap(
          Column(
            children: [
              AppButton.secondary(label: 'A', onPressed: () {}),
              AppButton.text(label: 'B', onPressed: () {}),
            ],
          ),
        ),
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('shows icon next to label', (tester) async {
      await tester.pumpWidget(
        wrap(AppButton(label: 'Novo', icon: Icons.add, onPressed: () {})),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
