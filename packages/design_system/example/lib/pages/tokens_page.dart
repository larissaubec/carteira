import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class TokensPage extends StatelessWidget {
  const TokensPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;
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
    final text = Theme.of(context).textTheme;
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

    return AppScaffold(
      title: 'Tokens',
      actions: const [ThemeModeButton()],
      body: ListView(
        children: [
          const SectionHeader(title: 'Cores'),
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
                      const Gap.xs(),
                      Text(name, style: text.bodySmall),
                    ],
                  ),
                ),
            ],
          ),
          const SectionHeader(title: 'Tipografia'),
          for (final (name, style) in styles)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(name, style: style),
            ),
          const SectionHeader(title: 'Espaçamento'),
          for (final (name, value) in [
            ('xs', AppSpacing.xs),
            ('sm', AppSpacing.sm),
            ('md', AppSpacing.md),
            ('lg', AppSpacing.lg),
            ('xl', AppSpacing.xl),
            ('xxl', AppSpacing.xxl),
          ])
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
                  const Gap.sm(),
                  Text('${value.toInt()} pt', style: text.bodySmall),
                ],
              ),
            ),
          const SectionHeader(title: 'Raio'),
          Row(
            children: [
              for (final (name, radius) in [
                ('sm', AppRadius.smAll),
                ('md', AppRadius.mdAll),
                ('lg', AppRadius.lgAll),
                ('pill', AppRadius.pillAll),
              ]) ...[
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
                const Gap.sm(),
              ],
            ],
          ),
          const Gap.xxl(),
        ],
      ),
    );
  }
}
