import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/strings.dart';

/// One segment of the [TypeFilter]. [type] null means every type.
enum _TypeOption {
  all(null, Strings.allTypes),
  income(TransactionType.income, Strings.income),
  expense(TransactionType.expense, Strings.expense),
  transfer(TransactionType.transfer, Strings.transferShort);

  const _TypeOption(this.type, this.label);

  final TransactionType? type;
  final String label;

  static _TypeOption of(TransactionType? type) =>
      values.firstWhere((option) => option.type == type);
}

/// "Todos | Receita | Despesa | Transf." segmented control.
class TypeFilter extends StatelessWidget {
  const TypeFilter({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final TransactionType? selected;
  final ValueChanged<TransactionType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_TypeOption>(
      showSelectedIcon: false,
      segments: [
        for (final option in _TypeOption.values)
          ButtonSegment<_TypeOption>(
            value: option,
            label: Text(option.label, maxLines: 1, softWrap: false),
          ),
      ],
      selected: {_TypeOption.of(selected)},
      onSelectionChanged: (selection) => onChanged(selection.first.type),
    );
  }
}
