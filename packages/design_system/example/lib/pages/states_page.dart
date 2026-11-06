import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class StatesPage extends StatefulWidget {
  const StatesPage({super.key});

  @override
  State<StatesPage> createState() => _StatesPageState();
}

class _StatesPageState extends State<StatesPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final views = <Widget>[
      const StateView.loading(message: 'Carregando lançamentos…'),
      StateView.empty(
        message: 'Nenhum lançamento neste mês',
        actionLabel: 'Adicionar',
        onAction: () {},
      ),
      StateView.error(
        message: 'Não foi possível carregar. Verifique sua conexão.',
        onRetry: () {},
      ),
    ];
    return AppScaffold(
      title: 'Estados',
      actions: const [ThemeModeButton()],
      body: views[_index],
      bottom: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.hourglass_top),
            label: 'Loading',
          ),
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            label: 'Empty',
          ),
          NavigationDestination(
            icon: Icon(Icons.error_outline),
            label: 'Error',
          ),
        ],
      ),
    );
  }
}
