import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/home_scroll_provider.dart';
import '../../providers/rental_provider.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final List<int> _navHistory = [0];

  int _locationToIndex(String location) {
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/trip')) return 2;
    if (location.startsWith('/map')) return 3;
    if (location.startsWith('/rental')) return 4;
    return 0;
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == 0 && _locationToIndex(GoRouterState.of(context).uri.toString()) == 0) {
      Provider.of<HomeScrollProvider>(context, listen: false).scrollToTop();
    }
    if (_navHistory.isEmpty || _navHistory.last != index) {
      _navHistory.remove(index);
      _navHistory.add(index);
    }
    _navigate(context, index);
  }

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/explore');
        break;
      case 2:
        context.go('/trip');
        break;
      case 3:
        context.go('/map');
        break;
      case 4:
        context.go('/rental');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _locationToIndex(location);

    if (_navHistory.isEmpty || _navHistory.last != currentIndex) {
      _navHistory.remove(currentIndex);
      _navHistory.add(currentIndex);
    }

    final language = context.watch<LanguageProvider>();

    final rental = context.watch<RentalProvider>();
    final isOjekActive = rental.rentalStatus == 'onTrip' && rental.isOjek && rental.selectedDriver != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_navHistory.length > 1) {
          setState(() {
            _navHistory.removeLast();
            final prevIndex = _navHistory.last;
            _navigate(context, prevIndex);
          });
        } else if (_navHistory.length == 1 && _navHistory.first != 0) {
          setState(() {
            _navHistory.clear();
            _navHistory.add(0);
            _navigate(context, 0);
          });
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(child: widget.child),
            if (isOjekActive)
              _buildActiveOjekBanner(context, rental, language),
          ],
        ),
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
                  _NavItem(
                      icon: Icons.home_rounded,
                      label: language.translate('home'),
                      index: 0,
                      currentIndex: currentIndex,
                      onTap: (i) => _onNavTap(context, i)),
                  _NavItem(
                      icon: Icons.explore_rounded,
                      label: language.translate('explore'),
                      index: 1,
                      currentIndex: currentIndex,
                      onTap: (i) => _onNavTap(context, i)),
                  _TripNavItem(
                      isActive: currentIndex == 2,
                      label: language.translate('trip'),
                      onTap: () => _onNavTap(context, 2)),
                  _NavItem(
                      icon: Icons.map_rounded,
                      label: language.translate('map'),
                      index: 3,
                      currentIndex: currentIndex,
                      onTap: (i) => _onNavTap(context, i)),
                  _NavItem(
                      icon: Icons.car_rental_rounded,
                      label: language.translate('rental'),
                      index: 4,
                      currentIndex: currentIndex,
                      onTap: (i) => _onNavTap(context, i)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveOjekBanner(BuildContext context, RentalProvider rental, LanguageProvider language) {
    final driver = rental.selectedDriver!;
    final pay = rental.currentPayment;
    final rentalId = pay?.id ?? 'temp';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        border: const Border(
          top: BorderSide(color: AppColors.accent, width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white10,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sports_motorsports_rounded, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  language.translateText(id: 'Perjalanan RO-JEK Aktif', en: 'Active RO-JEK Trip'),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  language.translateText(
                    id: 'Driver: ${driver.name}',
                    en: 'Driver: ${driver.name}',
                  ),
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () => context.push('/chat/${driver.id}'),
                icon: const Icon(Icons.chat_rounded, size: 14, color: AppColors.primaryDark),
                label: Text(
                  language.translateText(id: 'Chat', en: 'Chat'),
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => context.push('/driver-tracking/$rentalId'),
                icon: const Icon(Icons.my_location_rounded, size: 14, color: Colors.white),
                label: Text(
                  language.translateText(id: 'Lacak', en: 'Track'),
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
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
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
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
  final String label;
  final VoidCallback onTap;

  const _TripNavItem({required this.isActive, required this.label, required this.onTap});

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
    );
  }
}
