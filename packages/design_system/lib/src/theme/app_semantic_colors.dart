import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';

/// Colors that carry meaning in a finance app and have no slot in
/// [ColorScheme]: income, expense, transfer and warning.
///
/// Registered as a [ThemeExtension] so widgets read them with
/// `context.semanticColors`.
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.income,
    required this.expense,
    required this.transfer,
    required this.warning,
    required this.muted,
  });

  factory AppSemanticColors.fromPalette(AppColorPalette palette) {
    return AppSemanticColors(
      income: palette.income,
      expense: palette.expense,
      transfer: palette.transfer,
      warning: palette.warning,
      muted: palette.onSurfaceMuted,
    );
  }

  final Color income;
  final Color expense;
  final Color transfer;
  final Color warning;

  /// Secondary text color.
  final Color muted;

  @override
  AppSemanticColors copyWith({
    Color? income,
    Color? expense,
    Color? transfer,
    Color? warning,
    Color? muted,
  }) {
    return AppSemanticColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      transfer: transfer ?? this.transfer,
      warning: warning ?? this.warning,
      muted: muted ?? this.muted,
    );
  }

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      transfer: Color.lerp(transfer, other.transfer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
    );
  }
}

/// Shortcut: `context.semanticColors.income`.
extension SemanticColorsContext on BuildContext {
  AppSemanticColors get semanticColors {
    final colors = Theme.of(this).extension<AppSemanticColors>();
    assert(
      colors != null,
      'AppSemanticColors is missing. Use AppTheme.light() or AppTheme.dark().',
    );
    return colors!;
  }
}
