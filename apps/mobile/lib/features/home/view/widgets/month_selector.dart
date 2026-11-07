import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import '../../../../utils/month_label.dart';

/// Horizontal row of month chips (`out/2026`, `set/2026`, ...), newest
/// first. Scrolls sideways when the months do not fit.
class MonthSelector extends StatelessWidget {
  const MonthSelector({
    required this.months,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  /// Month keys, `YYYY-MM`.
  final List<String> months;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screen,
          vertical: AppSpacing.xs,
        ),
        itemCount: months.length,
        separatorBuilder: (_, _) => const Gap.sm(),
        itemBuilder: (context, index) {
          final month = months[index];
          return ChoiceChip(
            key: ValueKey('month_$month'),
            label: Text(formatMonthShort(month)),
            selected: month == selected,
            onSelected: (_) => onSelected(month),
          );
        },
      ),
    );
  }
}
