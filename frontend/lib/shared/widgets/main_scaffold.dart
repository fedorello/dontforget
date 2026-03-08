import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/medicines')) return 1;
    if (location.startsWith('/shopping')) return 2;
    if (location.startsWith('/todos')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final l10n = AppL10n.of(context)!;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: _locationToIndex(location),
          onDestinationSelected: (i) {
            switch (i) {
              case 0: context.go('/today');
              case 1: context.go('/medicines');
              case 2: context.go('/shopping');
              case 3: context.go('/todos');
            }
          },
          destinations: [
            NavigationDestination(icon: const Icon(Icons.wb_sunny_outlined), selectedIcon: const Icon(Icons.wb_sunny), label: l10n.nav_today),
            NavigationDestination(icon: const Icon(Icons.medication_outlined), selectedIcon: const Icon(Icons.medication), label: l10n.nav_medicines),
            NavigationDestination(icon: const Icon(Icons.shopping_cart_outlined), selectedIcon: const Icon(Icons.shopping_cart), label: l10n.nav_shopping),
            NavigationDestination(icon: const Icon(Icons.check_circle_outline), selectedIcon: const Icon(Icons.check_circle), label: l10n.nav_todos),
          ],
        ),
      ),
    );
  }
}
