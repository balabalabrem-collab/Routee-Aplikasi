import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/data/driver_data.dart';
import '../../core/models/driver_model.dart';
import '../../providers/rental_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/contact_admin_sheet.dart';
import '../../widgets/common/bounceable.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  String _selectedType = 'Motor';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final drivers = DriverData.byVehicleType(_selectedType);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sewa Transportasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.headset_mic_rounded),
            tooltip: 'Hubungi Admin',
            onPressed: () => ContactAdminSheet.show(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B2314), Color(0xFF6D4C2A), Color(0xFF8B6914)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🚗', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sewa Kendaraan', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text('Pilih driver terbaik untuk perjalanan heritage-mu', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70, height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Price indicator / Selector Buttons combined
                Row(
                  children: [
                    _PriceBadge(
                      icon: '🛵',
                      label: 'Motor',
                      price: 'Rp 10.000/jam',
                      isActive: _selectedType == 'Motor',
                      onTap: () => setState(() => _selectedType = 'Motor'),
                    ),
                    const SizedBox(width: 10),
                    _PriceBadge(
                      icon: '🚗',
                      label: 'Mobil',
                      price: 'Rp 40.000/jam',
                      isActive: _selectedType == 'Mobil',
                      onTap: () => setState(() => _selectedType = 'Mobil'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Driver list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: drivers.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DriverCard(
                  driver: drivers[i],
                  isLoggedIn: auth.isLoggedIn,
                  onBook: () => _handleBook(drivers[i], auth.isLoggedIn),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ContactAdminSheet.show(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.chat, color: Colors.white),
        label: Text('Bantuan', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
      ),    );
  }

  void _handleBook(DriverModel driver, bool isLoggedIn) {
    if (!isLoggedIn) {
      _showLoginDialog();
      return;
    }

    final rental = context.read<RentalProvider>();
    rental.selectDriver(driver);
    context.push('/payment');
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lock_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Login Diperlukan', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'Kamu perlu login atau buat akun untuk menyewa transportasi.',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Nanti', style: GoogleFonts.poppins(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/login');
            },
            child: Text('Login', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
class _PriceBadge extends StatelessWidget {
  final String icon;
  final String label;
  final String price;
  final bool isActive;
  final VoidCallback onTap;

  const _PriceBadge({
    required this.icon,
    required this.label,
    required this.price,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Bounceable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive ? AppColors.accent : Colors.white24,
              width: isActive ? 2.0 : 1.0,
            ),
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
            ],
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      price,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: isActive ? AppColors.accentLight : Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isActive)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.accent,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final DriverModel driver;
  final bool isLoggedIn;
  final VoidCallback onBook;

  const _DriverCard({required this.driver, required this.isLoggedIn, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Driver avatar
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent, width: 2),
                  ),
                  child: const Center(child: Icon(Icons.person_rounded, size: 28, color: AppColors.primary)),
                ),
                const SizedBox(width: 14),
                // Driver info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(driver.name, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
                          const SizedBox(width: 2),
                          Text('${driver.rating}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent)),
                          const SizedBox(width: 8),
                          Text('•', style: GoogleFonts.poppins(color: AppColors.textMuted)),
                          const SizedBox(width: 8),
                          Text('${driver.totalTrips} trips', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Availability
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text('Online', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.success)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Vehicle info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _VehicleInfoChip(icon: Icons.two_wheeler, label: driver.vehicleName),
                  const SizedBox(width: 16),
                  _VehicleInfoChip(icon: Icons.confirmation_number_outlined, label: driver.plateNumber),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Book button
            SizedBox(
              width: double.infinity,
              child: Bounceable(
                onTap: onBook,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6D4C2A), Color(0xFF4A3219)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isLoggedIn ? Icons.directions_car_rounded : Icons.lock_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          isLoggedIn ? 'Sewa Sekarang' : 'Login untuk Sewa',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _VehicleInfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
