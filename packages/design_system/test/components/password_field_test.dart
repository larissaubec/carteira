import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  group('PasswordField', () {
    testWidgets('starts obscured and toggles on eye tap', (tester) async {
      await tester.pumpWidget(wrap(const PasswordField()));
      TextField field() => tester.widget<TextField>(find.byType(TextField));

      expect(field().obscureText, isTrue);
      await tester.tap(find.byKey(const Key('password_toggle')));
      await tester.pump();
      expect(field().obscureText, isFalse);
      await tester.tap(find.byKey(const Key('password_toggle')));
      await tester.pump();
      expect(field().obscureText, isTrue);
    });

    testWidgets('strength bar reacts to typing', (tester) async {
      await tester.pumpWidget(wrap(const PasswordField(showStrength: true)));
      expect(find.text('Fraca'), findsNothing);

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();
      expect(find.text('Fraca'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Abcdef12!xyz');
      await tester.pump();
      expect(find.text('Forte'), findsOneWidget);
    });

    test('strengthOf classifies passwords', () {
      expect(PasswordField.strengthOf(''), PasswordStrength.empty);
      expect(PasswordField.strengthOf('123456'), PasswordStrength.weak);
      expect(PasswordField.strengthOf('abcdef12'), PasswordStrength.fair);
      expect(PasswordField.strengthOf('Abcdef12!xyz'), PasswordStrength.strong);
    });
  });
}
