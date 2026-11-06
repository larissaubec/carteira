import 'package:flutter/material.dart';

import '../theme/app_semantic_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

/// One row of a "by category" summary: label, amount, percentage and a bar
/// proportional to [share].
///
/// [amount] arrives formatted, like everywhere else in the package; the
/// widget does not know what a category or a transaction is.
class CategoryBar extends StatelessWidget {
  const CategoryBar({
    required this.label,
    required this.amount,
    required this.share,
    super.key,
  });

  final String label;

  /// Already formatted, e.g. "R\$ 702,20".
  final String amount;

  /// Fraction of the total, from 0 to 1. Values outside are clamped.
  final double share;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = context.semanticColors.muted;
    final fraction = share.clamp(0.0, 1.0).toDouble();
    final percent = '${(fraction * 100).round()}%';
    return Semantics(
      label: '$label, $amount, $percent',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  amount,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFeatures: AppTypography.tabularFigures,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  width: 40,
                  child: Text(
                    percent,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: AppRadius.pillAll,
              child: SizedBox(
                height: 6,
                child: ColoredBox(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: fraction,
                    child: ColoredBox(color: theme.colorScheme.primary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
