import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../core/models/itinerary_model.dart';
import '../core/services/notification_service.dart';

class NavigationProvider extends ChangeNotifier {
  LatLng? _userLocation;
  double? _distanceToNext; // in meters
  bool _nearbyAlertShown = false;
  bool _arrivedAlertShown = false;
  bool _locationPermissionGranted = false;
  bool _isLoadingRoute = false;
  List<LatLng> _routePoints = [];
  String _statusMessage = '';

  StreamSubscription<Position>? _positionStream;
  final NotificationService _notifService = NotificationService();

  // Thresholds
  static const double _nearbyRadius = 300.0;   // meters - show "hampir sampai"
  static const double _arrivedRadius = 80.0;   // meters - mark as arrived

  // Getters
  LatLng? get userLocation => _userLocation;
  double? get distanceToNext => _distanceToNext;
  bool get nearbyAlertShown => _nearbyAlertShown;
  bool get arrivedAlertShown => _arrivedAlertShown;
  bool get locationPermissionGranted => _locationPermissionGranted;
  bool get isLoadingRoute => _isLoadingRoute;
  List<LatLng> get routePoints => _routePoints;
  String get statusMessage => _statusMessage;

  bool get isNearby => (_distanceToNext != null) && (_distanceToNext! <= _nearbyRadius) && (_distanceToNext! > _arrivedRadius);
  bool get hasArrived => (_distanceToNext != null) && (_distanceToNext! <= _arrivedRadius);

  /// Request location permission and start GPS stream
  Future<bool> requestPermissionAndStart() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      _locationPermissionGranted = false;
      _statusMessage = 'Izin lokasi ditolak. Aktifkan di pengaturan.';
      notifyListeners();
      return false;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _locationPermissionGranted = false;
      _statusMessage = 'GPS tidak aktif. Nyalakan GPS terlebih dahulu.';
      notifyListeners();
      return false;
    }

    _locationPermissionGranted = true;
    _statusMessage = 'Melacak posisi...';
    notifyListeners();
    return true;
  }

  /// Start live GPS tracking
  void startTracking(ItinerarySpot? targetSpot, Function(ItinerarySpot) onArrived) {
    _stopStream();
    _nearbyAlertShown = false;
    _arrivedAlertShown = false;

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // update every 10 meters
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: settings).listen(
      (Position pos) {
        _userLocation = LatLng(pos.latitude, pos.longitude);

        if (targetSpot != null) {
          final dest = LatLng(
            _getDestLat(targetSpot.id),
            _getDestLng(targetSpot.id),
          );

          if (dest.latitude != 0 && dest.longitude != 0) {
            _distanceToNext = Geolocator.distanceBetween(
              pos.latitude, pos.longitude,
              dest.latitude, dest.longitude,
            );

            // Nearby alert (300m)
            if (_distanceToNext! <= _nearbyRadius && !_nearbyAlertShown) {
              _nearbyAlertShown = true;
              _notifService.showNearbyAlert(targetSpot.name);
            }

            // Arrived alert (80m)
            if (_distanceToNext! <= _arrivedRadius && !_arrivedAlertShown) {
              _arrivedAlertShown = true;
              _notifService.showArrivedAlert(targetSpot.name);
              onArrived(targetSpot);
              // Reset for next destination
              _nearbyAlertShown = false;
              _arrivedAlertShown = false;
              _distanceToNext = null;
            }
          }
        }
        notifyListeners();
      },
      onError: (_) {
        _statusMessage = 'Error mengambil lokasi GPS.';
        notifyListeners();
      },
    );
  }

  /// Fetch OSRM route between all itinerary spots
  Future<void> fetchRoute(List<ItinerarySpot> spots, LatLng? startLocation) async {
    if (spots.isEmpty) return;

    _isLoadingRoute = true;
    _routePoints = [];
    notifyListeners();

    try {
      // Build coordinate list: [userLoc (if available)] + all spots
      final List<LatLng> waypoints = [];
      if (startLocation != null) {
        waypoints.add(startLocation);
      }

      for (final spot in spots) {
        final lat = _getDestLat(spot.id);
        final lng = _getDestLng(spot.id);
        if (lat != 0 && lng != 0) {
          waypoints.add(LatLng(lat, lng));
        }
      }

      if (waypoints.length < 2) {
        _isLoadingRoute = false;
        notifyListeners();
        return;
      }

      // OSRM API: driving profile
      final coords = waypoints
          .map((p) => '${p.longitude},${p.latitude}')
          .join(';');
      final url =
          'http://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List;
        if (routes.isNotEmpty) {
          final geometry = routes[0]['geometry'];
          final coordinates = geometry['coordinates'] as List;
          _routePoints = coordinates
              .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
              .toList();
        }
      }
    } catch (_) {
      // Fallback: garis lurus antar titik
      _routePoints = [];
    }

    _isLoadingRoute = false;
    notifyListeners();
  }

  void resetAlerts() {
    _nearbyAlertShown = false;
    _arrivedAlertShown = false;
    _distanceToNext = null;
    notifyListeners();
  }

  void stopTracking() {
    _stopStream();
    _userLocation = null;
    _distanceToNext = null;
    _routePoints = [];
    _nearbyAlertShown = false;
    _arrivedAlertShown = false;
    notifyListeners();
  }

  void _stopStream() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  @override
  void dispose() {
    _stopStream();
    super.dispose();
  }

  // ── Lookup lat/lng from destinations data ──────────────────
  // These match the ids in destinations_data.dart
  static const Map<String, List<double>> _coords = {
    'maspati':                 [-7.2480, 112.7343],
    'dejavasche':              [-7.2289, 112.7371],
    'tunjungan':               [-7.2586, 112.7379],
    'gedung-siola':            [-7.2583, 112.7367],
    'kota-lama':               [-7.2275, 112.7342],
    'alun-alun':               [-7.2647, 112.7403],
    'taman-bungkul':           [-7.2922, 112.7358],
    'kenjeran':                [-7.2232, 112.7857],
    'kalimas':                 [-7.2465, 112.7479],
    'chenghoo':                [-7.2665, 112.7519],
    'ampel':                   [-7.2307, 112.7451],
    'langgar-dukur':           [-7.2562, 112.7437],
    'klenteng-kya-kya':        [-7.2319, 112.7388],
    'sanggar-agung':           [-7.2230, 112.7868],
    'masjid-agung':            [-7.3047, 112.7315],
    'makam-bungkul':           [-7.2924, 112.7360],
    'masjid-boto-putih':       [-7.2263, 112.7485],
    'gereja-kepanjen':         [-7.2393, 112.7368],
    'klenteng-hong-tiek-hian': [-7.2287, 112.7431],
    'kampung-peneleh':         [-7.2562, 112.7430],
    'lahir-bung-karno':        [-7.2541, 112.7441],
    'museum-pendidikan':       [-7.2559, 112.7375],
    'museum-olahraga':         [-7.2758, 112.7235],
    'museum-10-nov':           [-7.2458, 112.7381],
    'kalimas-prestasi':        [-7.2598, 112.7433],
    'museum-dr-soetomo':       [-7.2476, 112.7350],
    'museum-wr-supratman':     [-7.2530, 112.7565],
    'museum-house-of-sampoerna':[-7.2305, 112.7341],
    'tugu-pahlawan':           [-7.2460, 112.7380],
    'jembatan-merah':          [-7.2346, 112.7386],
    'penjara-kalisosok':       [-7.2285, 112.7335],
    'gedung-internatio':       [-7.2355, 112.7372],
    'makam-sawunggaling':      [-7.3073, 112.6685],
    'punden-larasati':         [-7.2950, 112.7520],
    'makam-pangeran-benowo':   [-7.2605, 112.6255],
    'museum-balai-pemuda':     [-7.2645, 112.7402],
  };

  double _getDestLat(String id) => _coords[id]?[0] ?? 0;
  double _getDestLng(String id) => _coords[id]?[1] ?? 0;

  LatLng? getSpotLatLng(String id) {
    final c = _coords[id];
    if (c == null) return null;
    return LatLng(c[0], c[1]);
  }
}
