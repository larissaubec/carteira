import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import '../main.dart';

/// Shows every token on screen. Built with plain Material widgets only: the
/// design system has no components yet.
class TokensPage extends StatelessWidget {
  const TokensPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;
    final text = Theme.of(context).textTheme;
    final swatches = <(String, Color)>[
      ('primary', scheme.primary),
      ('primaryContainer', scheme.primaryContainer),
      ('surface', scheme.surface),
      ('surfaceContainerHighest', scheme.surfaceContainerHighest),
      ('outline', scheme.outline),
      ('income', semantic.income),
      ('expense', semantic.expense),
      ('transfer', semantic.transfer),
      ('warning', semantic.warning),
      ('muted', semantic.muted),
    ];
    final styles = <(String, TextStyle?)>[
      ('displayLarge', text.displayLarge),
      ('headlineMedium', text.headlineMedium),
      ('titleLarge', text.titleLarge),
      ('titleMedium', text.titleMedium),
      ('bodyLarge', text.bodyLarge),
      ('bodyMedium', text.bodyMedium),
      ('bodySmall', text.bodySmall),
      ('labelSmall', text.labelSmall),
    ];
    final spacings = <(String, double)>[
      ('xs', AppSpacing.xs),
      ('sm', AppSpacing.sm),
      ('md', AppSpacing.md),
      ('lg', AppSpacing.lg),
      ('xl', AppSpacing.xl),
      ('xxl', AppSpacing.xxl),
    ];
    final radii = <(String, BorderRadius)>[
      ('sm', AppRadius.smAll),
      ('md', AppRadius.mdAll),
      ('lg', AppRadius.lgAll),
      ('pill', AppRadius.pillAll),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tokens'),
        actions: const [ThemeModeButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          _Heading('Cores', style: text.labelSmall),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final (name, color) in swatches)
                SizedBox(
                  width: 104,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: AppRadius.mdAll,
                          border: Border.all(color: scheme.outline),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(name, style: text.bodySmall),
                    ],
                  ),
                ),
            ],
          ),
          _Heading('Tipografia', style: text.labelSmall),
          for (final (name, style) in styles)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(name, style: style),
            ),
          _Heading('Espaçamento', style: text.labelSmall),
          for (final (name, value) in spacings)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  SizedBox(width: 40, child: Text(name, style: text.bodySmall)),
                  Container(
                    width: value * 4,
                    height: 12,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('${value.toInt()} pt', style: text.bodySmall),
                ],
              ),
            ),
          _Heading('Raio', style: text.labelSmall),
          Row(
            children: [
              for (final (name, radius) in radii) ...[
                Container(
                  width: 56,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(color: scheme.primary, width: 2),
                  ),
                  child: Text(name, style: text.bodySmall),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.title, {this.style});

  final String title;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.sm),
      child: Text(
        title.toUpperCase(),
        style: style?.copyWith(color: context.semanticColors.muted),
      ),
    );
  }
}
