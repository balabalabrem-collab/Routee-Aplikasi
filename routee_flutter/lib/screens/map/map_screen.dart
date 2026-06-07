import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/data/destinations_data.dart';
import '../../core/models/destination_model.dart';
import '../../core/models/itinerary_model.dart';
import '../../providers/trip_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../widgets/common/bounceable.dart';

// ─── Map Mode ──────────────────────────────────────────
enum MapMode { explore, navigate }

class MapScreen extends StatefulWidget {
  final MapMode mode;
  const MapScreen({super.key, this.mode = MapMode.explore});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  DestinationModel? _selectedDest;
  String _filterCategory = 'Semua';
  late MapMode _mode;

  // For nearby alert banner animation
  bool _showNearbyBanner = false;
  String _nearbyBannerText = '';
  Timer? _bannerTimer;

  // Pulse animation for active marker
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const LatLng _surabayaCenter = LatLng(-7.2575, 112.7521);
  final categories = ['Semua', 'Heritage', 'Religi'];

  @override
  void initState() {
    super.initState();
    _mode = widget.mode;

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (_mode == MapMode.navigate) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startNavigationMode());
    }
  }

  Future<void> _startNavigationMode() async {
    final navProvider = context.read<NavigationProvider>();
    final tripProvider = context.read<TripProvider>();

    // Request location permission
    final granted = await navProvider.requestPermissionAndStart();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(navProvider.statusMessage, style: GoogleFonts.poppins()),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
      return;
    }

    // Start GPS tracking
    final activeSpot = tripProvider.activeSpot;
    navProvider.startTracking(activeSpot, (arrivedSpot) {
      // Mark as visited
      final idx = tripProvider.currentItinerary?.spots.indexOf(arrivedSpot) ?? -1;
      if (idx >= 0) {
        tripProvider.markSpotVisited(idx);
        if (mounted) {
          context.read<BookmarkProvider>().markAsVisited(arrivedSpot.id);
        }
      }
      // Reset alerts for next spot
      navProvider.resetAlerts();
      // Start tracking new active spot
      final nextSpot = tripProvider.activeSpot;
      navProvider.startTracking(nextSpot, (_) {});

      // Show in-app arrival banner
      _showBanner('🎉 Selamat datang di ${arrivedSpot.name}!');

      // Fetch new route for next spot
      if (tripProvider.currentItinerary != null) {
        navProvider.fetchRoute(
          tripProvider.currentItinerary!.spots,
          navProvider.userLocation,
        );
      }
    });

    // Fetch OSRM route
    if (tripProvider.currentItinerary != null) {
      final userLoc = navProvider.userLocation; // might be null initially
      navProvider.fetchRoute(tripProvider.currentItinerary!.spots, userLoc);
    }
  }

  void _showBanner(String text) {
    setState(() {
      _showNearbyBanner = true;
      _nearbyBannerText = text;
    });
    _bannerTimer?.cancel();
    _bannerTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showNearbyBanner = false);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  List<DestinationModel> get _filteredDestinations {
    if (_filterCategory == 'Semua') return DestinationsData.destinations;
    return DestinationsData.destinations.where((d) => d.category == _filterCategory).toList();
  }

  Color _markerColor(String category) {
    switch (category) {
      case 'Heritage': return AppColors.heritageFg;
      case 'Religi': return AppColors.religiFg;
      default: return AppColors.culinaryFg;
    }
  }

  IconData _markerIcon(String category) {
    switch (category) {
      case 'Heritage': return Icons.account_balance_rounded;
      case 'Religi': return Icons.mosque_rounded;
      default: return Icons.restaurant_rounded;
    }
  }

  void _moveToDestination(DestinationModel dest) {
    setState(() => _selectedDest = dest);
    _mapController.move(LatLng(dest.lat, dest.lng), 15.5);
  }

  void _stopNavigation() {
    context.read<NavigationProvider>().stopTracking();
    context.read<TripProvider>().stopNavigation();
    setState(() => _mode = MapMode.explore);
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final tripProvider = context.watch<TripProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ─── THE MAP ───────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _surabayaCenter,
              initialZoom: 12.5,
              minZoom: 10,
              maxZoom: 18,
              onTap: (_, __) {
                if (_mode == MapMode.explore) {
                  setState(() => _selectedDest = null);
                }
              },
            ),
            children: [
              // Tile Layer
              TileLayer(
                urlTemplate: 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.routee.routee_flutter',
                retinaMode: false,
              ),

              // ── NAVIGATE MODE: OSRM Route polyline ──────
              if (_mode == MapMode.navigate && navProvider.routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: navProvider.routePoints,
                      color: AppColors.primary,
                      strokeWidth: 5.0,
                      borderColor: AppColors.accent.withOpacity(0.5),
                      borderStrokeWidth: 2.0,
                    ),
                  ],
                ),

              // ── NAVIGATE MODE: Itinerary stop markers ───
              if (_mode == MapMode.navigate && tripProvider.currentItinerary != null)
                MarkerLayer(
                  markers: _buildNavigateMarkers(
                    tripProvider.currentItinerary!.spots,
                    tripProvider.activeSpotIndex,
                    tripProvider.visitedSpots,
                    navProvider,
                  ),
                ),

              // ── EXPLORE MODE: Destination markers ───────
              if (_mode == MapMode.explore)
                MarkerLayer(
                  markers: _filteredDestinations.map((dest) {
                    final isSelected = _selectedDest?.id == dest.id;
                    final color = _markerColor(dest.category);
                    final icon = _markerIcon(dest.category);

                    return Marker(
                      point: LatLng(dest.lat, dest.lng),
                      width: isSelected ? 56 : 44,
                      height: isSelected ? 56 : 44,
                      child: Bounceable(
                        onTap: () => _moveToDestination(dest),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected ? color : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: color,
                              width: isSelected ? 0 : 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.35),
                                blurRadius: isSelected ? 16 : 8,
                                spreadRadius: isSelected ? 2 : 0,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            icon,
                            size: isSelected ? 26 : 20,
                            color: isSelected ? Colors.white : color,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

              // ── Live user location dot ───────────────────
              if (navProvider.userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: navProvider.userLocation!,
                      width: 52,
                      height: 52,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (_, child) => Transform.scale(
                          scale: _pulseAnimation.value,
                          child: child,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 52, height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 24, height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2196F3).withOpacity(0.4),
                                    blurRadius: 10, spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

              // Attribution
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),

          // ─── TOP HEADER ────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  children: [
                    // Navigate mode header
                    if (_mode == MapMode.navigate)
                      _NavigateHeader(
                        onStop: _stopNavigation,
                        tripProvider: tripProvider,
                        navProvider: navProvider,
                      )
                    // Explore mode header
                    else ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withOpacity(0.82),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.0),
                              boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 16, offset: const Offset(0, 4))],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.map_rounded, color: AppColors.primary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Peta Destinasi', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                      Text('Tap marker untuk detail destinasi', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${_filteredDestinations.length} titik',
                                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Category filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: categories.map((cat) {
                            final isSelected = _filterCategory == cat;
                            Color chipColor;
                            switch (cat) {
                              case 'Heritage': chipColor = AppColors.heritageFg; break;
                              case 'Religi': chipColor = AppColors.religiFg; break;
                              default: chipColor = AppColors.primary;
                            }
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Bounceable(
                                onTap: () => setState(() {
                                  _filterCategory = cat;
                                  _selectedDest = null;
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? chipColor : AppColors.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: isSelected ? chipColor : AppColors.divider),
                                    boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8)],
                                  ),
                                  child: Text(
                                    cat == 'Semua' ? '🗺️  $cat' : cat == 'Heritage' ? '🏛  $cat' : '🕌  $cat',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12, fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ─── NEARBY BANNER (in-app alert) ──────────────
          if (_showNearbyBanner)
            Positioned(
              top: 120, left: 16, right: 16,
              child: _NearbyBanner(
                text: _nearbyBannerText,
                onDismiss: () => setState(() => _showNearbyBanner = false),
              ),
            ),

          // ─── NAVIGATE MODE: Route loading indicator ─────
          if (_mode == MapMode.navigate && navProvider.isLoadingRoute)
            Positioned(
              top: 120, left: 16, right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Text('Mengambil rute jalan...', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),

          // ─── NAVIGATE MODE: Nearby alert banner ─────────
          if (_mode == MapMode.navigate && navProvider.isNearby && !_showNearbyBanner)
            Positioned(
              top: 120, left: 16, right: 16,
              child: _NearbyBanner(
                text: '📍 Hampir sampai — ${_formatDist(navProvider.distanceToNext ?? 0)} lagi!',
                color: const Color(0xFFFF9800),
                onDismiss: () {},
              ),
            ),

          // ─── EXPLORE MODE: Selected destination card ────
          if (_mode == MapMode.explore && _selectedDest != null)
            Positioned(
              bottom: 16, left: 16, right: 16,
              child: _SelectedDestCard(
                destination: _selectedDest!,
                onClose: () => setState(() => _selectedDest = null),
                onDetail: () => context.push('/detail/${_selectedDest!.id}'),
              ),
            ),

          // ─── EXPLORE MODE: Destinations legend ──────────
          if (_mode == MapMode.explore && _selectedDest == null)
            Positioned(
              bottom: 16, left: 16, right: 16,
              child: _MapLegend(destinations: _filteredDestinations, onSelect: _moveToDestination),
            ),

          // ─── NAVIGATE MODE: Active spot panel ───────────
          if (_mode == MapMode.navigate)
            Positioned(
              bottom: 16, left: 16, right: 16,
              child: _NavigateBottomPanel(
                tripProvider: tripProvider,
                navProvider: navProvider,
                onSpotTap: (index) {
                  final spot = tripProvider.currentItinerary?.spots[index];
                  if (spot != null) {
                    final latLng = navProvider.getSpotLatLng(spot.id);
                    if (latLng != null) {
                      _mapController.move(latLng, 15.5);
                    }
                    tripProvider.setActiveSpot(index);
                  }
                },
              ),
            ),

          // ─── ZOOM CONTROLS ─────────────────────────────
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.35,
            child: Column(
              children: [
                _ZoomBtn(icon: Icons.add_rounded, onTap: () {
                  final z = _mapController.camera.zoom;
                  _mapController.move(_mapController.camera.center, z + 1);
                }),
                const SizedBox(height: 8),
                _ZoomBtn(icon: Icons.remove_rounded, onTap: () {
                  final z = _mapController.camera.zoom;
                  _mapController.move(_mapController.camera.center, z - 1);
                }),
                const SizedBox(height: 8),
                _ZoomBtn(
                  icon: navProvider.userLocation != null
                      ? Icons.my_location_rounded
                      : Icons.location_searching_rounded,
                  color: navProvider.userLocation != null ? const Color(0xFF2196F3) : null,
                  onTap: () {
                    if (navProvider.userLocation != null) {
                      _mapController.move(navProvider.userLocation!, 15.5);
                    } else {
                      _mapController.move(_surabayaCenter, 12.5);
                      setState(() => _selectedDest = null);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildNavigateMarkers(
    List<ItinerarySpot> spots,
    int activeIndex,
    Set<int> visited,
    NavigationProvider navProvider,
  ) {
    return spots.asMap().entries.map((entry) {
      final i = entry.key;
      final spot = entry.value;
      final latLng = navProvider.getSpotLatLng(spot.id);
      if (latLng == null) return null;

      final isActive = i == activeIndex;
      final isVisited = visited.contains(i);

      Color bgColor;
      Color borderColor;
      if (isVisited) {
        bgColor = Colors.grey.shade400;
        borderColor = Colors.grey.shade300;
      } else if (isActive) {
        bgColor = AppColors.primary;
        borderColor = Colors.white;
      } else {
        bgColor = Colors.white;
        borderColor = AppColors.primary;
      }

      return Marker(
        point: latLng,
        width: isActive ? 60 : 44,
        height: isActive ? 60 : 44,
        child: Bounceable(
          onTap: () {
            _mapController.move(latLng, 15.5);
            context.read<TripProvider>().setActiveSpot(i);
          },
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (_, child) => Transform.scale(
              scale: isActive ? _pulseAnimation.value : 1.0,
              child: child,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: isActive ? 3 : 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(isActive ? 0.5 : 0.15),
                    blurRadius: isActive ? 16 : 6,
                    spreadRadius: isActive ? 2 : 0,
                  ),
                ],
              ),
              child: Center(
                child: isVisited
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                    : Text(
                        '${i + 1}',
                        style: GoogleFonts.poppins(
                          fontSize: isActive ? 16 : 13,
                          fontWeight: FontWeight.w800,
                          color: isActive ? Colors.white : AppColors.primary,
                        ),
                      ),
              ),
            ),
          ),
        ),
      );
    }).whereType<Marker>().toList();
  }

  String _formatDist(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.toInt()} m';
  }
}

// ─── Navigate Mode Header ───────────────────────────────────
class _NavigateHeader extends StatelessWidget {
  final VoidCallback onStop;
  final TripProvider tripProvider;
  final NavigationProvider navProvider;

  const _NavigateHeader({required this.onStop, required this.tripProvider, required this.navProvider});

  @override
  Widget build(BuildContext context) {
    final spots = tripProvider.currentItinerary?.spots ?? [];
    final visited = tripProvider.visitedSpots.length;
    final total = spots.length;
    final progress = total > 0 ? visited / total : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.88),
                AppColors.primaryDark.withOpacity(0.88),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.navigation_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🗺️ Mode Navigasi Aktif',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                  Bounceable(
                    onTap: onStop,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Selesai', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('$visited dari $total destinasi dikunjungi', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70)),
                  const Spacer(),
                  if (navProvider.distanceToNext != null && navProvider.distanceToNext! > 80)
                    Text(
                      '📍 ${_formatDist(navProvider.distanceToNext!)} ke tujuan',
                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDist(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.toInt()} m';
  }
}

// ─── Nearby Banner ──────────────────────────────────────────
class _NearbyBanner extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onDismiss;

  const _NearbyBanner({
    required this.text,
    this.color = const Color(0xFF4CAF50),
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(text, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
            Bounceable(
              onTap: onDismiss,
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.close_rounded, color: Colors.white70, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Navigate Bottom Panel ──────────────────────────────────
class _NavigateBottomPanel extends StatelessWidget {
  final TripProvider tripProvider;
  final NavigationProvider navProvider;
  final Function(int) onSpotTap;

  const _NavigateBottomPanel({
    required this.tripProvider,
    required this.navProvider,
    required this.onSpotTap,
  });

  @override
  Widget build(BuildContext context) {
    final itinerary = tripProvider.currentItinerary;
    if (itinerary == null) return const SizedBox.shrink();

    final spots = itinerary.spots;
    final activeIndex = tripProvider.activeSpotIndex;
    final visited = tripProvider.visitedSpots;
    final isAllDone = tripProvider.isAllVisited;

    if (isAllDone) {
      return _AllDonePanel(totalSpots: spots.length);
    }

    final activeSpot = activeIndex < spots.length ? spots[activeIndex] : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mini stop indicator row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: spots.asMap().entries.map((e) {
              final i = e.key;
              final spot = e.value;
              final isActive = i == activeIndex;
              final isDone = visited.contains(i);
              final color = isDone ? Colors.grey : AppColors.primary;

              return Bounceable(
                onTap: () => onSpotTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8, bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : (isDone ? Colors.grey.shade200 : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.4)),
                    boxShadow: isActive ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8)] : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isDone) const Icon(Icons.check_circle_rounded, size: 12, color: Colors.grey),
                      if (!isDone) Text('${i + 1}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: isActive ? Colors.white : color)),
                      const SizedBox(width: 4),
                      Text(
                        spot.name.split(' ').take(2).join(' '),
                        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: isActive ? Colors.white : (isDone ? Colors.grey : AppColors.primary)),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Active spot card
        if (activeSpot != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.82),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.0),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 6))],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top bar
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      color: AppColors.primary.withOpacity(0.85),
                      child: Row(
                        children: [
                          const Icon(Icons.navigation_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text('Menuju Stop ${activeIndex + 1}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                          const Spacer(),
                          if (navProvider.distanceToNext != null && navProvider.distanceToNext! > 80)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                _formatDist(navProvider.distanceToNext!),
                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Spot info row
                    Row(
                      children: [
                        SizedBox(
                          width: 100, height: 90,
                          child: Image.asset(
                            activeSpot.image, fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(color: AppColors.surfaceVariant),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activeSpot.name,
                                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, size: 11, color: AppColors.textMuted),
                                    const SizedBox(width: 3),
                                    Text(activeSpot.timeLabel, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted)),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.hourglass_bottom_rounded, size: 11, color: AppColors.textMuted),
                                    const SizedBox(width: 3),
                                    Text(activeSpot.duration, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Bounceable(
                                      onTap: () {
                                        tripProvider.markSpotVisited(activeIndex);
                                        context.read<BookmarkProvider>().markAsVisited(activeSpot.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Selesai mengunjungi ${activeSpot.name}!'),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Tandai Selesai',
                                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
    );
  }

  String _formatDist(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.toInt()} m';
  }
}

// ─── All Done Panel ─────────────────────────────────────────
class _AllDonePanel extends StatelessWidget {
  final int totalSpots;
  const _AllDonePanel({required this.totalSpots});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF81C784)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF4CAF50).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          const Text('🏁', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Perjalanan Selesai!', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('Semua $totalSpots destinasi telah dikunjungi 🎉', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ),
          Bounceable(
            onTap: () => context.go('/trip'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(10)),
              child: Text('Kembali', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Selected Destination Card (Explore Mode) ───────────────
class _SelectedDestCard extends StatelessWidget {
  final DestinationModel destination;
  final VoidCallback onClose;
  final VoidCallback onDetail;

  const _SelectedDestCard({required this.destination, required this.onClose, required this.onDetail});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String icon;
    switch (destination.category) {
      case 'Heritage': bg = AppColors.heritageBg; fg = AppColors.heritageFg; icon = '🏛'; break;
      case 'Religi': bg = AppColors.religiBg; fg = AppColors.religiFg; icon = '🕌'; break;
      default: bg = AppColors.culinaryBg; fg = AppColors.culinaryFg; icon = '🍜';
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.82),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.0),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              SizedBox(
                width: 100, height: 100,
                child: Image.asset(destination.image, fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(color: AppColors.surfaceVariant,
                    child: Icon(Icons.image_rounded, size: 40, color: AppColors.textMuted))),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
                            child: Text('$icon ${destination.category}', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: fg)),
                          ),
                          const Spacer(),
                          Bounceable(
                            onTap: onClose,
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(destination.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(destination.location, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('★ ${destination.rating}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accent)),
                          const SizedBox(width: 8),
                          Text('· ${destination.ticket}', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                          const Spacer(),
                          Bounceable(
                            onTap: onDetail,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                              child: Text('Detail', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Map Legend (Explore Mode) ──────────────────────────────
class _MapLegend extends StatelessWidget {
  final List<DestinationModel> destinations;
  final Function(DestinationModel) onSelect;

  const _MapLegend({required this.destinations, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.82),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.0),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${destinations.length} Destinasi di Peta', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: destinations.length > 6 ? 6 : destinations.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) {
                    final dest = destinations[i];
                    Color color;
                    switch (dest.category) {
                      case 'Heritage': color = AppColors.heritageFg; break;
                      case 'Religi': color = AppColors.religiFg; break;
                      default: color = AppColors.culinaryFg;
                    }
                    return Bounceable(
                      onTap: () => onSelect(dest),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Text(
                          dest.name.split(' ').take(2).join(' '),
                          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: color),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Zoom Button ────────────────────────────────────────────
class _ZoomBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  const _ZoomBtn({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Bounceable(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Icon(icon, size: 20, color: color ?? AppColors.textPrimary),
      ),
    );
  }
}
