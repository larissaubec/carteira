import 'package:flutter/material.dart';

import '../theme/app_semantic_colors.dart';
import '../tokens/app_spacing.dart';
import 'app_button.dart';

enum _StateKind { loading, empty, error }

/// Full-area placeholder for the three non-content states of a screen.
///
/// ```dart
/// StateView.loading()
/// StateView.empty(message: 'Nenhum lançamento neste mês')
/// StateView.error(message: 'Sem conexão', onRetry: vm.load.execute)
/// ```
class StateView extends StatelessWidget {
  const StateView.loading({super.key, this.message})
    : _kind = _StateKind.loading,
      icon = null,
      actionLabel = null,
      onAction = null;

  const StateView.empty({
    required String this.message,
    super.key,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  }) : _kind = _StateKind.empty;

  const StateView.error({
    required String this.message,
    super.key,
    VoidCallback? onRetry,
    this.icon = Icons.error_outline,
    this.actionLabel = 'Tentar novamente',
  }) : _kind = _StateKind.error,
       onAction = onRetry;

  final _StateKind _kind;
  final String? message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semanticColors;

    final Widget visual = switch (_kind) {
      _StateKind.loading => const SizedBox.square(
        dimension: 36,
        child: CircularProgressIndicator.adaptive(),
      ),
      _StateKind.empty => Icon(icon, size: 48, color: semantic.muted),
      _StateKind.error => Icon(icon, size: 48, color: semantic.expense),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            visual,
            if (message != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: semantic.muted,
                ),
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton.secondary(
                label: actionLabel!,
                onPressed: onAction,
                expanded: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
