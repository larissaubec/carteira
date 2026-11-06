import 'package:flutter/material.dart';

import '../tokens/app_spacing.dart';

/// Fixed empty space on the spacing scale. Works inside both [Row] and
/// [Column] because it sets width and height alike.
class Gap extends StatelessWidget {
  const Gap(this.size, {super.key});

  const Gap.xxs({super.key}) : size = AppSpacing.xxs;
  const Gap.xs({super.key}) : size = AppSpacing.xs;
  const Gap.sm({super.key}) : size = AppSpacing.sm;
  const Gap.md({super.key}) : size = AppSpacing.md;
  const Gap.lg({super.key}) : size = AppSpacing.lg;
  const Gap.xl({super.key}) : size = AppSpacing.xl;
  const Gap.xxl({super.key}) : size = AppSpacing.xxl;

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size);
}

/// Divider with vertical breathing room, for lists and forms.
class EmptyDivider extends StatelessWidget {
  const EmptyDivider({super.key, this.indent = 0});

  /// Left inset, to align the line with tile content.
  final double indent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Divider(indent: indent),
    );
  }
}
