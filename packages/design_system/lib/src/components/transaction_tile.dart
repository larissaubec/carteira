import 'package:flutter/material.dart';

import '../theme/app_semantic_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import 'money_text.dart';

/// Kind of movement a [TransactionTile] represents. Lives in the design
/// system so the package stays independent from the domain models.
enum TransactionKind { income, expense, transfer }

/// One row of the transactions list.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.kind,
    required this.title,
    required this.amount,
    super.key,
    this.subtitle,
    this.onTap,
  });

  final TransactionKind kind;
  final String title;

  /// Already formatted, e.g. "R\$ 89,90".
  final String amount;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final theme = Theme.of(context);
    final (icon, color, tone) = switch (kind) {
      TransactionKind.income => (
        Icons.arrow_downward_rounded,
        semantic.income,
        MoneyTone.income,
      ),
      TransactionKind.expense => (
        Icons.arrow_upward_rounded,
        semantic.expense,
        MoneyTone.expense,
      ),
      TransactionKind.transfer => (
        Icons.swap_horiz_rounded,
        semantic.transfer,
        MoneyTone.neutral,
      ),
    };

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: AppRadius.mdAll,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall,
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: semantic.muted),
            ),
      trailing: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.sm),
        child: MoneyText(amount, tone: tone, signed: true),
      ),
    );
  }
}
