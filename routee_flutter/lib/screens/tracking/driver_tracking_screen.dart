import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
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

  // Simulated positions & realistic street routing points
  final List<LatLng> _routePoints = [
    const LatLng(-7.2505, 112.7388),
    const LatLng(-7.2515, 112.7388),
    const LatLng(-7.2515, 112.7420),
    const LatLng(-7.2545, 112.7422),
    const LatLng(-7.2545, 112.7392),
    const LatLng(-7.2575, 112.7392),
    const LatLng(-7.2580, 112.7400),
  ];
  int _currentPathIndex = 0;
  LatLng _driverPosition = const LatLng(-7.2505, 112.7388);
  final LatLng _userPosition = const LatLng(-7.2580, 112.7400);
  double _eta = 8.0; // minutes
  double _distance = 1.2; // km

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _driverPosition = _routePoints.first;

    // Simulate driver movement along the street route points
    _movementTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_currentPathIndex < _routePoints.length - 1) {
          _currentPathIndex++;
          _driverPosition = _routePoints[_currentPathIndex];
          
          // Calculate progress percentage
          double progress = _currentPathIndex / (_routePoints.length - 1);
          _distance = (1.2 * (1.0 - progress)).clamp(0.0, 1.2);
          _eta = (8.0 * (1.0 - progress)).clamp(0.0, 8.0);
        } else {
          timer.cancel();
          _distance = 0.0;
          _eta = 0.0;
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

  @override
  Widget build(BuildContext context) {
    final rental = context.watch<RentalProvider>();
    final driver = rental.selectedDriver;
    final isMotor = rental.selectedVehicleType == 'Motor';

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userPosition,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.routee.flutter',
              ),

              // Curved route line along streets
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    color: AppColors.primary.withOpacity(0.3),
                    strokeWidth: 4,
                  ),
                  Polyline(
                    points: _routePoints.sublist(_currentPathIndex),
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
                  // User marker
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

                    // Actions
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
                                title: Text('Batalkan Rental?', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
                                content: Text('Apakah kamu yakin ingin membatalkan penyewaan ini?', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
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
