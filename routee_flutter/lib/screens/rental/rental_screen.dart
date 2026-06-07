import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/data/driver_data.dart';
import '../../core/data/destinations_data.dart';
import '../../core/models/itinerary_model.dart';
import '../../providers/rental_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/contact_admin_sheet.dart';
import '../../widgets/common/bounceable.dart';

class RentalScreen extends StatefulWidget {
  const RentalScreen({super.key});

  @override
  State<RentalScreen> createState() => _RentalScreenState();
}

class _RentalScreenState extends State<RentalScreen> {
  int _selectedTab = 0; // 0: Sewa Motor/Mobil, 1: RO-JEK Ojek Online
  final _formatter = NumberFormat('#,###', 'id_ID');

  String _ojekStart = 'Stasiun Gubeng';
  late String _ojekDest1;
  late String _ojekDest2;
  String _ojekDest3 = '-';
  String _ojekDest4 = '-';
  String _ojekTime = '09:00 WIB';
  int _ojekHours = 2; // Default 2 Jam

  @override
  void initState() {
    super.initState();
    // Initialize defaults from DestinationsData
    final list = DestinationsData.destinations;
    _ojekDest1 = list.isNotEmpty ? list[0].name : 'Monumen Kapal Selam';
    _ojekDest2 = list.length > 1 ? list[1].name : 'Tugu Pahlawan';
  }

  double _getDistance(double lat1, double lng1, double lat2, double lng2) {
    const double p = 0.017453292519943295;
    final double a = 0.5 - math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) * math.cos(lat2 * p) *
            (1 - math.cos((lng2 - lng1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
  }

  String _formatRp(int amount) => 'Rp ${_formatter.format(amount)}';

  void _showSewaUnitDetailDialog(String vehicleType) {
    final drivers = DriverData.byVehicleType(vehicleType);
    if (drivers.isEmpty) return;
    final driver = drivers.first; // Pick the first available driver for this unit

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Detail Unit Sewa $vehicleType',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              // Driver Avatar
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 3),
                ),
                child: const Center(child: Icon(Icons.person_rounded, size: 36, color: AppColors.primary)),
              ),
              const SizedBox(height: 12),
              // Driver Name
              Text(
                driver.name,
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              // Rating & Trips
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: AppColors.accent),
                  Text(
                    ' ${driver.rating} • ${driver.totalTrips} Trips',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 10),
              // Vehicle details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Nama Kendaraan', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                  Text(driver.vehicleName, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Plat Nomor', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                  Text(driver.plateNumber, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Jenis Kendaraan', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                  Text(driver.vehicleType, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tarif Sewa', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                  Text(
                    vehicleType == 'Motor' ? 'Rp 10.000 / Jam' : 'Rp 40.000 / Jam',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Sewa Sekarang Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog
                    final rental = context.read<RentalProvider>();
                    rental.setIsOjek(false);
                    rental.selectDriver(driver);
                    rental.setVehicleType(vehicleType);
                    rental.setCustomPrice(null); // use hourly rate
                    context.push('/payment');
                  },
                  child: Text('Sewa Sekarang', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, inner) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppColors.primary,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              centerTitle: false,
              title: Text(
                'Persewaan Routee',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A3219), Color(0xFF6D4C2A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            // Segmented tab control
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TabButton(
                        label: 'Sewa Kendaraan',
                        icon: Icons.directions_car_rounded,
                        isActive: _selectedTab == 0,
                        onTap: () => setState(() => _selectedTab = 0),
                      ),
                    ),
                    Expanded(
                      child: _TabButton(
                        label: 'Ojek RO-JEK',
                        icon: Icons.two_wheeler_rounded,
                        isActive: _selectedTab == 1,
                        onTap: () => setState(() => _selectedTab = 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                child: _selectedTab == 0 ? _buildSewaTab() : _buildOjekTab(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // SEWA KENDARAAN (GUBENG CENTERED) TAB
  // ═══════════════════════════════════════════════════════
  Widget _buildSewaTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location Highlight Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📍', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terpusat di Stasiun Gubeng',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Layanan persewaan kami berlokasi di area sekitar Stasiun Gubeng Surabaya. Pengguna dipersilakan mendatangi persewaan secara langsung (bisa menggunakan KRL, Commuter Line, bis, atau ojek umum terlebih dahulu).',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Pilihan Unit Kendaraan',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),

        // Vehicle list cards
        _buildVehicleUnitCard(
          icon: '🛵',
          type: 'Motor',
          title: 'Sewa Motor Murah',
          desc: 'Unit terawat (Honda Vario 160, Yamaha NMAX). Lincah menyusuri jalanan Surabaya.',
          price: 'Rp 10.000 / Jam',
          included: ['Helm SNI', 'Jas Hujan', 'Kunci Ganda'],
        ),
        const SizedBox(height: 12),
        _buildVehicleUnitCard(
          icon: '🚗',
          type: 'Mobil',
          title: 'Sewa Mobil Nyaman',
          desc: 'Unit keluarga (Toyota Avanza, Daihatsu Xenia). Hemat dan dingin ber-AC.',
          price: 'Rp 40.000 / Jam',
          included: ['AC Dingin', 'Asuransi Perjalanan', 'Charger HP'],
        ),

        const SizedBox(height: 24),

        // Hubungi Admin CTA Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              const Text('✉️', style: TextStyle(fontSize: 32)),
              const SizedBox(height: 10),
              Text(
                'Ingin Memesan / Bertanya?',
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Silakan hubungi admin Routee secara langsung melalui WhatsApp atau Instagram resmi kami untuk ketersediaan unit dan koordinasi penjemputan.',
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Bounceable(
                      onTap: () => ContactAdminSheet.show(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF25D366).withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 16),
                            const SizedBox(width: 8),
                            Text('WhatsApp', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF25D366))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Bounceable(
                      onTap: () => ContactAdminSheet.show(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE1306C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE1306C).withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt_rounded, color: Color(0xFFE1306C), size: 16),
                            const SizedBox(width: 8),
                            Text('Instagram', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFFE1306C))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleUnitCard({
    required String icon,
    required String type,
    required String title,
    required String desc,
    required String price,
    required List<String> included,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Text(icon, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        price,
                        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: included.map((inc) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 10),
                          const SizedBox(width: 4),
                          Text(inc, style: GoogleFonts.poppins(fontSize: 9, color: AppColors.textMuted)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // OJEK ONLINE (RO-JEK) TAB
  // ═══════════════════════════════════════════════════════
  Widget _buildOjekTab() {
    final isLoggedIn = context.read<AuthProvider>().isLoggedIn;

    // Get coordinates for start point
    double startLat = -7.2653;
    double startLng = 112.7519;
    if (_ojekStart == 'Stasiun Pasar Turi') {
      startLat = -7.2483;
      startLng = 112.7364;
    } else if (_ojekStart == 'Terminal Purabaya') {
      startLat = -7.3524;
      startLng = 112.7244;
    }

    // Resolve destination coordinates
    double dest1Lat = startLat;
    double dest1Lng = startLng;
    double dest2Lat = startLat;
    double dest2Lng = startLng;
    double dest3Lat = startLat;
    double dest3Lng = startLng;
    double dest4Lat = startLat;
    double dest4Lng = startLng;

    for (var d in DestinationsData.destinations) {
      if (d.name == _ojekDest1) {
        dest1Lat = d.lat;
        dest1Lng = d.lng;
      }
      if (d.name == _ojekDest2) {
        dest2Lat = d.lat;
        dest2Lng = d.lng;
      }
      if (d.name == _ojekDest3) {
        dest3Lat = d.lat;
        dest3Lng = d.lng;
      }
      if (d.name == _ojekDest4) {
        dest4Lat = d.lat;
        dest4Lng = d.lng;
      }
    }

    // Calculate dynamic distance
    double totalKm = 0.0;
    totalKm += _getDistance(startLat, startLng, dest1Lat, dest1Lng);
    totalKm += _getDistance(dest1Lat, dest1Lng, dest2Lat, dest2Lng);

    if (_ojekDest3 != '-') {
      totalKm += _getDistance(dest2Lat, dest2Lng, dest3Lat, dest3Lng);
      if (_ojekDest4 != '-') {
        totalKm += _getDistance(dest3Lat, dest3Lng, dest4Lat, dest4Lng);
      }
    }

    // Calculate vehiclePrice based on durational rules: 2 hours = 15k, 4 hours = 35k, 6 hours = 50k
    int vehiclePrice = 15000;
    if (_ojekHours == 4) {
      vehiclePrice = 35000;
    } else if (_ojekHours == 6) {
      vehiclePrice = 50000;
    }

    // Calculate BBM: 10 Liters = 10k = 50km -> 200 per km
    final int bbmPrice = (totalKm * 200).round();
    const int jasaDriverPrice = 15000; // Flat driver service fee
    final int driverPrice = bbmPrice + jasaDriverPrice;
    final int basePrice = vehiclePrice + driverPrice;

    final terminalOptions = ['Stasiun Gubeng', 'Stasiun Pasar Turi', 'Terminal Purabaya'];
    final destinationOptions = DestinationsData.destinations.map((d) => d.name).toList();
    final destinationOptionsWithNone = ['-', ...destinationOptions];
    final timeOptions = ['09:00 WIB', '11:00 WIB', '13:00 WIB', '15:00 WIB', '17:00 WIB'];
    final durationOptions = [2, 4, 6];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner Ojek
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6D4C2A), Color(0xFF8B6914)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Text('🛵', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RO-JEK (Routee Ojek)',
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    Text(
                      'Layanan ojek khusus antar-destinasi trip dengan tarif transparan.',
                      style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text('Konfigurasi Pengantaran', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),

        // Configurations Inputs Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Start point
              Text('Titik Keberangkatan', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _ojekStart,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.train_rounded, color: AppColors.primary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: terminalOptions.map((t) => DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.poppins(fontSize: 12)))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _ojekStart = val);
                },
              ),
              const SizedBox(height: 14),

              // Destination 1
              Text('Destinasi Utama (Wajib)', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _ojekDest1,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.place_rounded, color: AppColors.primary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: destinationOptions.map((d) => DropdownMenuItem(value: d, child: Text(d, style: GoogleFonts.poppins(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _ojekDest1 = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 14),

              // Destination 2
              Text('Destinasi Kedua (Wajib)', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _ojekDest2,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.place_rounded, color: AppColors.primary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: destinationOptions.map((d) => DropdownMenuItem(value: d, child: Text(d, style: GoogleFonts.poppins(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _ojekDest2 = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 14),

              // Destination 3
              Text('Destinasi Ketiga (Opsional)', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _ojekDest3,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.add_location_rounded, color: AppColors.primary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: destinationOptionsWithNone.map((d) => DropdownMenuItem(value: d, child: Text(d == '-' ? 'Tidak Ada' : d, style: GoogleFonts.poppins(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _ojekDest3 = val;
                      if (val == '-') {
                        _ojekDest4 = '-';
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 14),

              // Destination 4
              Text('Destinasi Keempat (Opsional)', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _ojekDest4,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.add_location_rounded, color: AppColors.primary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: destinationOptionsWithNone.map((d) => DropdownMenuItem(value: d, child: Text(d == '-' ? 'Tidak Ada' : d, style: GoogleFonts.poppins(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
                onChanged: _ojekDest3 == '-' ? null : (val) {
                  if (val != null) {
                    setState(() => _ojekDest4 = val);
                  }
                },
              ),
              const SizedBox(height: 14),

              // Time picker / dropdown
              Text('Estimasi Waktu Penjemputan', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _ojekTime,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.schedule_rounded, color: AppColors.primary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: timeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.poppins(fontSize: 12)))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _ojekTime = val);
                },
              ),
              const SizedBox(height: 14),

              // Durasi Sewa
              Text('Durasi Perjalanan / Sewa Ojek', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                value: _ojekHours,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.av_timer_rounded, color: AppColors.primary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: durationOptions.map((h) => DropdownMenuItem<int>(value: h, child: Text('$h Jam', style: GoogleFonts.poppins(fontSize: 12)))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _ojekHours = val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Route info card
        Text('Informasi Penjemputan', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRouteSummaryItem(
                icon: Icons.train_rounded,
                label: 'Lokasi Penjemputan Awal',
                value: _ojekStart,
              ),
              const Divider(height: 20),
              _buildRouteSummaryItem(
                icon: Icons.schedule_rounded,
                label: 'Jadwal Penjemputan Driver',
                value: 'Standby & Jemput pukul $_ojekTime',
              ),
              const Divider(height: 20),
              _buildRouteSummaryItem(
                icon: Icons.alt_route_rounded,
                label: 'Estimasi Jarak Rute',
                value: '${totalKm.toStringAsFixed(1)} km',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Price breakdown card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accentSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rincian Biaya Ro-Jek', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
              const SizedBox(height: 8),
              _buildPriceRow('Penyewaan Kendaraan ($_ojekHours Jam)', _formatRp(vehiclePrice)),
              const SizedBox(height: 6),
              _buildPriceRow('Bahan Bakar Minyak (BBM ~${totalKm.toStringAsFixed(1)} km)', _formatRp(bbmPrice)),
              const SizedBox(height: 6),
              _buildPriceRow('Jasa Driver (Layanan Flat)', _formatRp(jasaDriverPrice)),
              const Divider(color: AppColors.accent, height: 20),
              _buildPriceRow('Total Biaya', _formatRp(basePrice), isBold: true),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Action Button to proceed to payment
        SizedBox(
          width: double.infinity,
          height: 52,
          child: Bounceable(
            onTap: () {
              if (!isLoggedIn) {
                _showLoginDialog();
                return;
              }

              final rental = context.read<RentalProvider>();
              rental.setIsOjek(true);
              rental.setPickupTime(_ojekTime);

              final List<String> route = [_ojekStart, _ojekDest1, _ojekDest2];
              if (_ojekDest3 != '-') {
                route.add(_ojekDest3);
                if (_ojekDest4 != '-') {
                  route.add(_ojekDest4);
                }
              }
              rental.setOjekRoute(route);
              rental.setCustomPrice(basePrice);

              final motorDrivers = DriverData.byVehicleType('Motor');
              if (motorDrivers.isNotEmpty) {
                rental.selectDriver(motorDrivers.first);
              }
              rental.setVehicleType('Motor');

              context.push('/payment');
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6D4C2A), Color(0xFF4A3219)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isLoggedIn ? Icons.sports_motorsports_rounded : Icons.lock_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isLoggedIn ? 'Pesan Ojek Sekarang' : 'Login untuk Memesan',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted)),
            Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isBold ? 14 : 12,
            color: isBold ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedRouteCard({
    required String title,
    required String desc,
    required String distance,
    required String stops,
    required int price,
    required VoidCallback onSelect,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _formatRp(price),
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.alt_route_rounded, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(distance, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted)),
              const SizedBox(width: 12),
              Icon(Icons.flag_rounded, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(stops, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted)),
              const Spacer(),
              Bounceable(
                onTap: onSelect,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Pilih Rute',
                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _applyRecommendedRoute({required String terminalName, required List<ItinerarySpot> spots}) {
    final trip = context.read<TripProvider>();
    final itinerary = ItineraryModel(
      terminalName: terminalName,
      hours: 6,
      spots: spots,
      food: const ItineraryFood(
        name: 'Kuliner Lokal Sekitar Rute',
        image: 'assets/images/placeholder.jpg',
        price: 25000,
        area: 'Surabaya',
      ),
      transport: const ['Ojek Online RO-JEK'],
    );
    trip.setItinerary(itinerary);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rute rekomendasi berhasil diterapkan di Trip!', style: GoogleFonts.poppins(fontSize: 12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleOjekBooking(int price, bool isLoggedIn) {
    if (!isLoggedIn) {
      _showLoginDialog();
      return;
    }

    final rental = context.read<RentalProvider>();
    // Select first available motor driver
    final motorDrivers = DriverData.byVehicleType('Motor');
    if (motorDrivers.isNotEmpty) {
      rental.selectDriver(motorDrivers.first);
    }
    rental.setVehicleType('Motor');
    rental.setCustomPrice(price);

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
          'Kamu perlu login atau buat akun untuk memesan ojek online.',
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

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Bounceable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
