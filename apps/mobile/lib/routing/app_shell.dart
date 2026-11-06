import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/strings.dart';

/// Bottom navigation shared by the signed-in tabs: "Lançamentos" and
/// "Perfil". Each tab keeps its own state (scroll, filters) while the other
/// is shown.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Tapping the current tab again goes back to its first screen.
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: Strings.tabTransactions,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: Strings.tabProfile,
          ),
        ],
      ),
    );
  }
}
