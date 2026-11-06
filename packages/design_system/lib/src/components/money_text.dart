import 'package:flutter/material.dart';

import '../theme/app_semantic_colors.dart';
import '../tokens/app_typography.dart';

/// Which semantic color a money figure takes.
enum MoneyTone { neutral, income, expense }

/// Size of a [MoneyText].
enum MoneySize { small, medium, large, display }

/// Money figure. The string arrives formatted by the caller
/// ("R\$ 1.234,56"); the widget only picks color and size.
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.value, {
    super.key,
    this.tone = MoneyTone.neutral,
    this.size = MoneySize.medium,
    this.signed = false,
  });

  final String value;
  final MoneyTone tone;
  final MoneySize size;

  /// Prefix "+" for income and "−" for expense.
  final bool signed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semanticColors;
    final color = switch (tone) {
      MoneyTone.neutral => theme.colorScheme.onSurface,
      MoneyTone.income => semantic.income,
      MoneyTone.expense => semantic.expense,
    };
    final base = switch (size) {
      MoneySize.small => AppTypography.bodySmall,
      MoneySize.medium => AppTypography.titleMedium,
      MoneySize.large => AppTypography.titleLarge,
      MoneySize.display => AppTypography.displayLarge,
    };
    final prefix = switch ((signed, tone)) {
      (true, MoneyTone.income) => '+',
      (true, MoneyTone.expense) => '−',
      _ => '',
    };
    return Text(
      '$prefix$value',
      style: base.copyWith(
        color: color,
        fontFeatures: AppTypography.tabularFigures,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
