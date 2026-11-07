import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class ListsPage extends StatelessWidget {
  const ListsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Listas',
      actions: const [ThemeModeButton()],
      padded: false,
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(title: 'BalanceCard'),
                BalanceCard(
                  balance: 'R\$ 5.289,55',
                  income: 'R\$ 8.500,00',
                  expense: 'R\$ 3.210,45',
                  monthLabel: 'Setembro 2026',
                ),
                SectionHeader(title: 'MoneyText'),
                Row(
                  children: [
                    MoneyText('R\$ 12,50', size: MoneySize.small),
                    Gap.lg(),
                    MoneyText(
                      'R\$ 12,50',
                      tone: MoneyTone.income,
                      signed: true,
                    ),
                    Gap.lg(),
                    MoneyText(
                      'R\$ 12,50',
                      tone: MoneyTone.expense,
                      size: MoneySize.large,
                      signed: true,
                    ),
                  ],
                ),
                SectionHeader(title: 'CategoryBar'),
                CategoryBar(
                  label: 'Alimentação',
                  amount: 'R\$ 702,20',
                  share: 0.38,
                ),
                CategoryBar(label: 'Moradia', amount: 'R\$ 1.850,00', share: 1),
                CategoryBar(
                  label: 'Uma categoria com nome comprido demais',
                  amount: 'R\$ 12,00',
                  share: 0.02,
                ),
                SectionHeader(title: 'TransactionTile'),
              ],
            ),
          ),
          TransactionTile(
            kind: TransactionKind.expense,
            title: 'Mercado',
            subtitle: 'Alimentação · Nubank',
            amount: 'R\$ 89,90',
            onTap: () {},
          ),
          TransactionTile(
            kind: TransactionKind.income,
            title: 'Salário',
            subtitle: 'Salário · Itaú',
            amount: 'R\$ 8.500,00',
            onTap: () {},
          ),
          TransactionTile(
            kind: TransactionKind.transfer,
            title: 'Reserva de emergência',
            subtitle: 'Nubank → Itaú',
            amount: 'R\$ 1.000,00',
            onTap: () {},
          ),
          const TransactionTile(
            kind: TransactionKind.expense,
            title: 'Um título comprido o bastante para ser cortado com reticências',
            subtitle: 'Sem categoria',
            amount: 'R\$ 1.234.567,89',
          ),
          const EmptyDivider(indent: AppSpacing.screen),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: SectionHeader(title: 'Hoje', actionLabel: 'Ver todos'),
          ),
        ],
      ),
    );
  }
}
