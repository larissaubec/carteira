import 'package:flutter/material.dart';

import '../theme/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import 'money_text.dart';

/// Summary card at the top of the home screen: balance of the month with
/// income and expense underneath.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    required this.balance,
    required this.income,
    required this.expense,
    super.key,
    this.title = 'Saldo do mês',
    this.monthLabel,
  });

  /// All three already formatted.
  final String balance;
  final String income;
  final String expense;
  final String title;

  /// E.g. "Setembro 2026".
  final String? monthLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = context.semanticColors.muted;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                  ),
                ),
                if (monthLabel != null)
                  Text(
                    monthLabel!,
                    style: theme.textTheme.labelSmall?.copyWith(color: muted),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            MoneyText(balance, size: MoneySize.display),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _Leg(
                    label: 'Entradas',
                    value: income,
                    tone: MoneyTone.income,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _Leg(
                    label: 'Saídas',
                    value: expense,
                    tone: MoneyTone.expense,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Leg extends StatelessWidget {
  const _Leg({required this.label, required this.value, required this.tone});

  final String label;
  final String value;
  final MoneyTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: context.semanticColors.muted,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        MoneyText(value, tone: tone, size: MoneySize.medium),
      ],
    );
  }
}
