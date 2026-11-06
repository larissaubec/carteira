import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  group('AppTextField', () {
    testWidgets('shows label, hint and error', (tester) async {
      await tester.pumpWidget(
        wrap(
          const AppTextField(
            label: 'E-mail',
            hint: 'voce@exemplo.com',
            errorText: 'Inválido',
          ),
        ),
      );
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Inválido'), findsOneWidget);
    });

    testWidgets('propagates text through controller and onChanged', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      String? changed;
      await tester.pumpWidget(
        wrap(
          AppTextField(
            label: 'Nome',
            controller: controller,
            onChanged: (v) => changed = v,
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Ana');
      expect(controller.text, 'Ana');
      expect(changed, 'Ana');
    });
  });
}
