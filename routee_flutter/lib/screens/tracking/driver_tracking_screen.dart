import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../core/data/destinations_data.dart';
import '../../core/data/terminal_data.dart';
import '../../providers/rental_provider.dart';
import '../../widgets/common/bounceable.dart';

class DriverTrackingScreen extends StatefulWidget {
  final String rentalId;
  const DriverTrackingScreen({super.key, required this.rentalId});

  @override
  State<DriverTrackingScreen> createState() => _DriverTrackingScreenState();
}

class _DriverTrackingScreenState extends State<DriverTrackingScreen> {
  late MapController _mapController;
  Timer? _movementTimer;

  // State phase: 'pickup', 'touring', 'completed'
  String _phase = 'pickup';
  List<LatLng> _currentRoute = [];
  int _currentPathIndex = 0;
  LatLng _driverPosition = const LatLng(-7.2505, 112.7388);
  final LatLng _userPosition = const LatLng(-7.2580, 112.7400);
  double _eta = 8.0; // minutes
  double _distance = 1.2; // km

  int _currentTargetIndex = 0;
  final List<String> _tourDestinations = [];
  final List<LatLng> _tourCoords = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initPickupRoute();
  }

  void _initPickupRoute() {
    _phase = 'pickup';
    // Pickup route: Static path leading to the user position
    _currentRoute = [
      const LatLng(-7.2505, 112.7388),
      const LatLng(-7.2515, 112.7388),
      const LatLng(-7.2515, 112.7420),
      const LatLng(-7.2545, 112.7422),
      const LatLng(-7.2545, 112.7392),
      const LatLng(-7.2575, 112.7392),
      const LatLng(-7.2580, 112.7400),
    ];
    _currentPathIndex = 0;
    _driverPosition = _currentRoute.first;
    _distance = 1.2;
    _eta = 8.0;
    _startTimer();
  }

  void _initTouringRoute(List<String> routeNames) {
    _phase = 'touring';
    _currentPathIndex = 0;
    _currentTargetIndex = 0;

    _tourDestinations.clear();
    _tourCoords.clear();

    // Start coordinate is the user position
    _tourCoords.add(_userPosition);

    for (var name in routeNames) {
      // Find destination
      final dest = DestinationsData.destinations.firstWhere(
        (d) => d.name.toLowerCase() == name.toLowerCase(),
        orElse: () => null as dynamic,
      );
      if (dest != null) {
        _tourDestinations.add(dest.name);
        _tourCoords.add(LatLng(dest.lat, dest.lng));
      } else {
        // Check terminal
        final term = TerminalData.terminals.firstWhere(
          (t) => t.name.toLowerCase() == name.toLowerCase(),
          orElse: () => null as dynamic,
        );
        if (term != null) {
          _tourDestinations.add(term.name);
          _tourCoords.add(LatLng(term.lat, term.lng));
        }
      }
    }

    // If no coordinates were resolved, add default fallback (Tugu Pahlawan)
    if (_tourDestinations.isEmpty) {
      _tourDestinations.add('Tugu Pahlawan');
      _tourCoords.add(const LatLng(-7.2458, 112.7378));
    }

    // Interpolate path legs
    final List<LatLng> fullPath = [];
    for (int i = 0; i < _tourCoords.length - 1; i++) {
      final start = _tourCoords[i];
      final end = _tourCoords[i + 1];
      final legPoints = _interpolate(start, end, 10);
      if (i > 0) {
        fullPath.addAll(legPoints.skip(1));
      } else {
        fullPath.addAll(legPoints);
      }
    }

    _currentRoute = fullPath;
    _driverPosition = _currentRoute.first;
    _distance = 3.5;
    _eta = 15.0;

    _startTimer();
  }

  List<LatLng> _interpolate(LatLng start, LatLng end, int steps) {
    final List<LatLng> list = [];
    for (int i = 0; i <= steps; i++) {
      final double t = i / steps;
      final double lat = start.latitude + (end.latitude - start.latitude) * t;
      final double lng = start.longitude + (end.longitude - start.longitude) * t;
      list.add(LatLng(lat, lng));
    }
    return list;
  }

  void _startTimer() {
    _movementTimer?.cancel();
    _movementTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_currentPathIndex < _currentRoute.length - 1) {
          _currentPathIndex++;
          _driverPosition = _currentRoute[_currentPathIndex];

          final double progress = _currentPathIndex / (_currentRoute.length - 1);
          if (_phase == 'pickup') {
            _distance = (1.2 * (1.0 - progress)).clamp(0.0, 1.2);
            _eta = (8.0 * (1.0 - progress)).clamp(0.0, 8.0);
          } else {
            _distance = (3.5 * (1.0 - progress)).clamp(0.0, 3.5);
            _eta = (15.0 * (1.0 - progress)).clamp(0.0, 15.0);

            // Dynamically calculate current destination target
            // 10 steps per leg
            final int legIndex = (_currentPathIndex / 10).floor().clamp(0, _tourDestinations.length - 1);
            _currentTargetIndex = legIndex;
          }
        } else {
          timer.cancel();
          _distance = 0.0;
          _eta = 0.0;
          if (_phase == 'pickup') {
            // Wait for user to tap "Mulai Perjalanan"
          } else {
            _phase = 'completed';
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _movementTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _showRatingBottomSheet() {
    int rating = 5;
    int selectedTip = 0;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          if (isSubmitting) {
            return Container(
              height: 380,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 20),
                    Text(
                      'Mengirim Ulasan...',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            );
          }

          final rental = context.read<RentalProvider>();
          final driver = rental.selectedDriver;

          return Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Perjalanan Selesai! 🎉',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bagaimana pelayanan driver Anda hari ini?',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Driver Profile
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accent, width: 2),
                      ),
                      child: const Icon(Icons.person, color: AppColors.primary, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver?.name ?? 'Driver',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Driver RO-JEK Heritage',
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 24),

                // Stars Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final isSelected = index < rating;
                    return GestureDetector(
                      onTap: () => setSheetState(() => rating = index + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: AnimatedScale(
                          scale: isSelected ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: Icon(
                            Icons.star_rounded,
                            size: 40,
                            color: isSelected ? const Color(0xFFFFC107) : AppColors.divider,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Tipping Options
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Berikan Tip untuk Driver (Opsional)',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _TipButton(
                      label: 'Rp 5K',
                      value: 5000,
                      isSelected: selectedTip == 5000,
                      onTap: () => setSheetState(() => selectedTip = selectedTip == 5000 ? 0 : 5000),
                    ),
                    _TipButton(
                      label: 'Rp 10K',
                      value: 10000,
                      isSelected: selectedTip == 10000,
                      onTap: () => setSheetState(() => selectedTip = selectedTip == 10000 ? 0 : 10000),
                    ),
                    _TipButton(
                      label: 'Rp 20K',
                      value: 20000,
                      isSelected: selectedTip == 20000,
                      onTap: () => setSheetState(() => selectedTip = selectedTip == 20000 ? 0 : 20000),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      setSheetState(() => isSubmitting = true);
                      await Future.delayed(const Duration(milliseconds: 1500));
                      if (mounted) {
                        rental.reset();
                        Navigator.pop(ctx); // close sheet
                        context.go('/'); // go home
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  'Terima kasih atas ulasan Anda! ❤️',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Kirim Ulasan',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rental = context.watch<RentalProvider>();
    final driver = rental.selectedDriver;
    final isMotor = rental.selectedVehicleType == 'Motor';

    // Status label at the bottom card
    String statusLabel = 'Driver sedang menuju lokasi penjemputan';
    if (_phase == 'pickup' && _distance == 0.0) {
      statusLabel = 'Driver telah tiba di lokasi penjemputan!';
    } else if (_phase == 'touring') {
      if (_currentTargetIndex < _tourDestinations.length) {
        statusLabel = 'Perjalanan Heritage: Menuju ${_tourDestinations[_currentTargetIndex]}';
      } else {
        statusLabel = 'Perjalanan selesai! Silakan selesaikan.';
      }
    } else if (_phase == 'completed') {
      statusLabel = 'Tiba di destinasi akhir! Perjalanan selesai.';
    }

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userPosition,
              initialZoom: 14.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.routee.flutter',
              ),

              // Polyline route path
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _currentRoute,
                    color: AppColors.primary.withOpacity(0.3),
                    strokeWidth: 4,
                  ),
                  if (_currentPathIndex < _currentRoute.length)
                    Polyline(
                      points: _currentRoute.sublist(_currentPathIndex),
                      color: AppColors.primary,
                      strokeWidth: 5,
                    ),
                ],
              ),

              // Markers
              MarkerLayer(
                markers: [
                  // Driver marker
                  Marker(
                    point: _driverPosition,
                    width: 48,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 10)],
                      ),
                      child: Icon(
                        isMotor ? Icons.two_wheeler_rounded : Icons.directions_car_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),

                  // User/Pickup marker (always at start)
                  Marker(
                    point: _userPosition,
                    width: 48,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 10)],
                      ),
                      child: const Icon(Icons.person_pin, color: Colors.white, size: 22),
                    ),
                  ),

                  // Tour destination points
                  if (_phase == 'touring' || _phase == 'completed') ...[
                    for (int i = 0; i < _tourCoords.length; i++) ...[
                      if (i > 0)
                        Marker(
                          point: _tourCoords[i],
                          width: 32,
                          height: 32,
                          child: Container(
                            decoration: BoxDecoration(
                              color: i - 1 <= _currentTargetIndex ? AppColors.primaryDark : AppColors.divider,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '$i',
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                    ]
                  ]
                ],
              ),
            ],
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)],
                ),
                child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
              ),
            ),
          ),

          // ETA badge
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    _eta > 0 ? '${_eta.toStringAsFixed(0)} menit' : 'Tiba!',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),

          // Bottom card
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -4))],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 16),

                    // Driver info
                    Row(
                      children: [
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.accent, width: 2),
                          ),
                          child: const Icon(Icons.person, color: AppColors.primary, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(driver?.name ?? 'Driver', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
                              Text('${driver?.vehicleName ?? ''} • ${driver?.plateNumber ?? ''}', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
                                Text(' ${driver?.rating ?? 0}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Status Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.accent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              statusLabel,
                              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ETA and distance
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              children: [
                                Text(_eta > 0 ? '~${_eta.toStringAsFixed(0)} min' : 'Tiba!', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                                Text('Estimasi', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(color: AppColors.accentSurface, borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              children: [
                                Text(_distance > 0 ? '${_distance.toStringAsFixed(1)} km' : '0 km', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.accent)),
                                Text('Jarak', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons based on simulation phase
                    if (_phase == 'pickup' && _distance == 0.0)
                      // Driver has arrived at pickup location
                      SizedBox(
                        width: double.infinity,
                        child: Bounceable(
                          onTap: () {
                            setState(() {
                              _initTouringRoute(rental.ojekRoute);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.success.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.navigation_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Mulai Perjalanan',
                                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    else if (_phase == 'completed')
                      // Tour completed
                      SizedBox(
                        width: double.infinity,
                        child: Bounceable(
                          onTap: _showRatingBottomSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.success.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Selesaikan Perjalanan',
                                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      // Driver is on the way (either for pickup or during the tour)
                      Row(
                        children: [
                          Expanded(
                            child: Bounceable(
                              onTap: () {
                                final driverId = driver?.id ?? '';
                                context.push('/chat/$driverId');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.chat_rounded, color: Colors.white, size: 18),
                                      const SizedBox(width: 8),
                                      Text('Hubungi Driver', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Bounceable(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: Text('Batalkan Perjalanan?', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
                                  content: Text('Apakah kamu yakin ingin membatalkan perjalanan ini?', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tidak')),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        rental.reset();
                                        context.go('/');
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                      child: const Text('Ya, Batalkan'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.error.withOpacity(0.3)),
                              ),
                              child: const Icon(Icons.close_rounded, color: AppColors.error, size: 20),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipButton extends StatelessWidget {
  final String label;
  final int value;
  final bool isSelected;
  final VoidCallback onTap;

  const _TipButton({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
