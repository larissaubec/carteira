import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    test('light theme is built from the light palette', () {
      final theme = AppTheme.light();
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, AppColors.light.primary);
      expect(theme.scaffoldBackgroundColor, AppColors.light.background);
    });

    test('dark theme is built from the dark palette', () {
      final theme = AppTheme.dark();
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, AppColors.dark.primary);
      expect(theme.scaffoldBackgroundColor, AppColors.dark.background);
    });

    test('both themes register AppSemanticColors', () {
      for (final theme in [AppTheme.light(), AppTheme.dark()]) {
        final semantic = theme.extension<AppSemanticColors>();
        expect(semantic, isNotNull);
        expect(semantic!.income, isNot(semantic.expense));
      }
    });

    testWidgets('context.semanticColors reads the extension', (tester) async {
      late AppSemanticColors colors;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Builder(
            builder: (context) {
              colors = context.semanticColors;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(colors.expense, AppColors.light.expense);
    });
  });
}
