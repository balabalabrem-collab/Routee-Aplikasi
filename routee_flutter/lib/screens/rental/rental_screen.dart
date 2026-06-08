import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/data/driver_data.dart';
import '../../core/data/destinations_data.dart';
import '../../core/data/terminal_data.dart';
import '../../core/models/itinerary_model.dart';
import '../../providers/rental_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
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

  String _deliverySpot = 'Stasiun Gubeng (Pusat)';
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



  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();
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
                language.translateText(id: 'Persewaan Routee', en: 'Routee Rental'),
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
                        label: language.translateText(id: 'Sewa Kendaraan', en: 'Rent Vehicle'),
                        icon: Icons.directions_car_rounded,
                        isActive: _selectedTab == 0,
                        onTap: () => setState(() => _selectedTab = 0),
                      ),
                    ),
                    Expanded(
                      child: _TabButton(
                        label: language.translateText(id: 'Ojek RO-JEK', en: 'RO-JEK Ojek'),
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
    final language = context.watch<LanguageProvider>();
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
                      language.translateText(id: 'Terpusat di Stasiun Gubeng', en: 'Centered at Gubeng Station'),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      language.translateText(
                        id: 'Layanan persewaan kami berlokasi di area sekitar Stasiun Gubeng Surabaya. Pengguna dipersilakan mendatangi persewaan secara langsung (bisa menggunakan KRL, Commuter Line, bis, atau ojek umum terlebih dahulu).',
                        en: 'Our rental service is located in the area around Surabaya Gubeng Station. Users are welcome to come directly to the rental location (can use KRL, Commuter Line, bus, or public ojek first).',
                      ),
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

        // Delivery Location Selector
        Text(
          language.translateText(id: 'Pilihan Titik Serah Terima Kendaraan', en: 'Delivery / Pickup Point Options'),
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _deliverySpot,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
              dropdownColor: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              items: [
                'Stasiun Gubeng (Pusat - Gratis)',
                'Stasiun Pasar Turi (+Rp 15.000)',
                'Bandara Juanda (+Rp 50.000)',
                'Hotel / Alamat Kustom (+Rp 20.000)',
              ].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
              onChanged: (newVal) {
                if (newVal != null) {
                  setState(() => _deliverySpot = newVal);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 20),

        Text(
          language.translateText(id: 'Pilihan Unit Kendaraan', en: 'Vehicle Unit Options'),
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),

        // Vehicle list cards
        _buildVehicleUnitCard(
          icon: '🛵',
          type: 'Motor',
          title: language.translateText(id: 'Sewa Motor Murah', en: 'Affordable Motorbike Rental'),
          desc: language.translateText(
            id: 'Unit terawat (Honda Vario 160, Yamaha NMAX). Lincah menyusuri jalanan Surabaya.',
            en: 'Well-maintained units (Honda Vario 160, Yamaha NMAX). Agile in navigating Surabaya streets.',
          ),
          price: language.translateText(id: 'Rp 10.000 / Jam', en: 'Rp 10,000 / Hr'),
          included: [
            language.translateText(id: 'Helm SNI', en: 'SNI Helmet'),
            language.translateText(id: 'Jas Hujan', en: 'Raincoat'),
            language.translateText(id: 'Kunci Ganda', en: 'Double Lock'),
          ],
        ),
        const SizedBox(height: 12),
        _buildVehicleUnitCard(
          icon: '🚗',
          type: 'Mobil',
          title: language.translateText(id: 'Sewa Mobil Nyaman', en: 'Comfortable Car Rental'),
          desc: language.translateText(
            id: 'Unit keluarga (Toyota Avanza, Daihatsu Xenia). Hemat dan dingin ber-AC.',
            en: 'Family units (Toyota Avanza, Daihatsu Xenia). Economical with cold AC.',
          ),
          price: language.translateText(id: 'Rp 40.000 / Jam', en: 'Rp 40,000 / Hr'),
          included: [
            language.translateText(id: 'AC Dingin', en: 'Cold AC'),
            language.translateText(id: 'Asuransi Perjalanan', en: 'Travel Insurance'),
            language.translateText(id: 'Charger HP', en: 'Phone Charger'),
          ],
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
                language.translateText(id: 'Ingin Memesan / Bertanya?', en: 'Want to Order / Inquire?'),
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                language.translateText(
                  id: 'Silakan hubungi admin Routee secara langsung melalui WhatsApp atau Instagram resmi kami untuk ketersediaan unit dan koordinasi penjemputan.',
                  en: 'Please contact Routee admin directly via our official WhatsApp or Instagram for unit availability and pickup coordination.',
                ),
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
                Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
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
                const SizedBox(height: 8),
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
    final language = context.watch<LanguageProvider>();
    final isLoggedIn = context.read<AuthProvider>().isLoggedIn;

    // Get coordinates for start point
    double startLat = -7.2653;
    double startLng = 112.7519;
    try {
      final matchedTerminal = TerminalData.terminals.firstWhere((t) => t.name == _ojekStart);
      startLat = matchedTerminal.lat;
      startLng = matchedTerminal.lng;
    } catch (_) {}

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

    // Calculate BBM: 20k = 10 Liters = 10km -> 2000 per km
    final int bbmPrice = (totalKm * 2000).round();
    const int jasaDriverPrice = 15000; // Flat driver service fee
    final int driverPrice = bbmPrice + jasaDriverPrice;
    final int basePrice = vehiclePrice + driverPrice;

    final terminalOptions = TerminalData.terminals.map((t) => t.name).toList();
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
                      language.translateText(
                        id: 'Layanan ojek khusus antar-destinasi trip dengan tarif transparan.',
                        en: 'Special ojek service between trip destinations with transparent rates.',
                      ),
                      style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(language.translateText(id: 'Konfigurasi Pengantaran', en: 'Delivery Configuration'), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
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
              Text(language.translateText(id: 'Titik Keberangkatan', en: 'Departure Point'), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                isExpanded: true,
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
              Text(language.translateText(id: 'Destinasi Utama (Wajib)', en: 'Main Destination (Required)'), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                isExpanded: true,
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
              Text(language.translateText(id: 'Destinasi Kedua (Wajib)', en: 'Second Destination (Required)'), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                isExpanded: true,
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
              Text(language.translateText(id: 'Destinasi Ketiga (Opsional)', en: 'Third Destination (Optional)'), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _ojekDest3,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.add_location_rounded, color: AppColors.primary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: destinationOptionsWithNone.map((d) => DropdownMenuItem(value: d, child: Text(d == '-' ? language.translateText(id: 'Tidak Ada', en: 'None') : d, style: GoogleFonts.poppins(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
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
              Text(language.translateText(id: 'Destinasi Keempat (Opsional)', en: 'Fourth Destination (Optional)'), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _ojekDest4,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.add_location_rounded, color: AppColors.primary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: destinationOptionsWithNone.map((d) => DropdownMenuItem(value: d, child: Text(d == '-' ? language.translateText(id: 'Tidak Ada', en: 'None') : d, style: GoogleFonts.poppins(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
                onChanged: _ojekDest3 == '-' ? null : (val) {
                  if (val != null) {
                    setState(() => _ojekDest4 = val);
                  }
                },
              ),
              const SizedBox(height: 14),

              // Time picker / dropdown
              Text(language.translateText(id: 'Estimasi Waktu Penjemputan', en: 'Estimated Pickup Time'), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                isExpanded: true,
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
              Text(language.translateText(id: 'Durasi Perjalanan / Sewa Ojek', en: 'Trip Duration / Ojek Rental'), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                isExpanded: true,
                value: _ojekHours,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.av_timer_rounded, color: AppColors.primary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: durationOptions.map((h) => DropdownMenuItem<int>(value: h, child: Text('$h ' + language.translateText(id: 'Jam', en: 'Hours'), style: GoogleFonts.poppins(fontSize: 12)))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _ojekHours = val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Route info card
        Text(language.translateText(id: 'Informasi Penjemputan', en: 'Pickup Information'), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
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
                label: language.translateText(id: 'Lokasi Penjemputan Awal', en: 'Initial Pickup Location'),
                value: _ojekStart,
              ),
              const Divider(height: 20),
              _buildRouteSummaryItem(
                icon: Icons.schedule_rounded,
                label: language.translateText(id: 'Jadwal Penjemputan Driver', en: 'Driver Pickup Schedule'),
                value: language.translateText(id: 'Standby & Jemput pukul $_ojekTime', en: 'Standby & Pickup at $_ojekTime'),
              ),
              const Divider(height: 20),
              _buildRouteSummaryItem(
                icon: Icons.alt_route_rounded,
                label: language.translateText(id: 'Estimasi Jarak Rute', en: 'Estimated Route Distance'),
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
              Text(language.translateText(id: 'Rincian Biaya Ro-Jek', en: 'Ro-Jek Price Details'), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
              const SizedBox(height: 8),
              _buildPriceRow(language.translateText(id: 'Penyewaan Kendaraan', en: 'Vehicle Rental') + ' ($_ojekHours ' + language.translateText(id: 'Jam', en: 'Hours') + ')', _formatRp(vehiclePrice)),
              const SizedBox(height: 6),
              _buildPriceRow(language.translateText(id: 'Jasa Driver & BBM', en: 'Driver Service & Fuel'), _formatRp(driverPrice)),
              const Divider(color: AppColors.accent, height: 20),
              _buildPriceRow(language.translateText(id: 'Total Biaya', en: 'Total Price'), _formatRp(basePrice), isBold: true),
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
                      isLoggedIn ? language.translateText(id: 'Pesan Ojek Sekarang', en: 'Order Ojek Now') : language.translateText(id: 'Login untuk Memesan', en: 'Login to Order'),
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



  void _showLoginDialog() {
    final language = context.read<LanguageProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lock_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(language.translateText(id: 'Login Diperlukan', en: 'Login Required'), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          language.translateText(
            id: 'Kamu perlu login atau buat akun untuk memesan ojek online.',
            en: 'You need to login or create an account to order an online ojek.',
          ),
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(language.translateText(id: 'Nanti', en: 'Later'), style: GoogleFonts.poppins(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/login');
            },
            child: Text(language.translateText(id: 'Login', en: 'Login'), style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
