import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  group('AppAvatar', () {
    test('initialsOf', () {
      expect(AppAvatar.initialsOf('Ana Ribeiro'), 'AR');
      expect(AppAvatar.initialsOf('Bruno de Costa'), 'BC');
      expect(AppAvatar.initialsOf('ana'), 'A');
      expect(AppAvatar.initialsOf('  '), '?');
    });

    testWidgets('falls back to initials without imageUrl', (tester) async {
      await tester.pumpWidget(wrap(const AppAvatar(name: 'Ana Ribeiro')));
      expect(find.text('AR'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('renders Image when imageUrl is given', (tester) async {
      await tester.pumpWidget(
        wrap(
          const AppAvatar(
            name: 'Ana Ribeiro',
            imageUrl: 'https://example.com/a.png',
          ),
        ),
      );
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
