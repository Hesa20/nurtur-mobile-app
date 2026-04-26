import 'package:flutter/material.dart';
import 'package:nurtur_app_wppl_agile/core/theme/app_colors.dart';
import 'package:nurtur_app_wppl_agile/features/home/domain/models/home_page_models.dart';

class HomeBottomNavigationBar extends StatelessWidget {
  const HomeBottomNavigationBar({
    super.key,
    required this.destinations,
    required this.selectedTab,
    this.onTabSelected,
  });

  final List<HomeBottomNavDestination> destinations;
  final HomeTabId selectedTab;
  final ValueChanged<HomeTabId>? onTabSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7FB),
          border: Border(
            top: BorderSide(color: AppColors.border.withValues(alpha: 0.65)),
          ),
        ),
        child: Row(
          children: [
            for (final destination in destinations)
              Expanded(
                child: _NavItem(
                  destination: destination,
                  selected: destination.tabId == selectedTab,
                  onTap: () => onTabSelected?.call(destination.tabId),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final HomeBottomNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  IconData _iconForTab(HomeTabId tabId) {
    switch (tabId) {
      case HomeTabId.beranda:
        return Icons.home_rounded;
      case HomeTabId.konsultasi:
        return Icons.forum_outlined;
      case HomeTabId.aktivitas:
        return Icons.assignment_outlined;
      case HomeTabId.profil:
        return Icons.person_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryPurple : const Color(0xFF9A9A9A);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          key: Key('home-bottom-nav-${destination.tabId.name}'),
          button: true,
          selected: selected,
          label: destination.label,
          child: Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_iconForTab(destination.tabId), color: color, size: 22),
                const SizedBox(height: 3),
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    height: 1.1,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
