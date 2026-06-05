import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/trip')) return 2;
    if (location.startsWith('/map')) return 3;
    if (location.startsWith('/umkm')) return 4;
    return 0;
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/'); break;
      case 1: context.go('/explore'); break;
      case 2: context.go('/trip'); break;
      case 3: context.go('/map'); break;
      case 4: context.go('/umkm'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _NavItem(icon: Icons.home_rounded, label: 'Home', index: 0, currentIndex: currentIndex, onTap: (i) => _onNavTap(context, i)),
                _NavItem(icon: Icons.explore_rounded, label: 'Explore', index: 1, currentIndex: currentIndex, onTap: (i) => _onNavTap(context, i)),
                _TripNavItem(isActive: currentIndex == 2, onTap: () => _onNavTap(context, 2)),
                _NavItem(icon: Icons.map_rounded, label: 'Peta', index: 3, currentIndex: currentIndex, onTap: (i) => _onNavTap(context, i)),
                _NavItem(icon: Icons.storefront_rounded, label: 'UMKM', index: 4, currentIndex: currentIndex, onTap: (i) => _onNavTap(context, i)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final Function(int) onTap;

  const _NavItem({
    required this.icon, required this.label, required this.index,
    required this.currentIndex, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isActive ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripNavItem extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _TripNavItem({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(
                        colors: [Color(0xFF6D4C2A), Color(0xFF4A3219)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF8B6914), Color(0xFF6D4C2A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.route_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 3),
            Text(
              'Trip',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
