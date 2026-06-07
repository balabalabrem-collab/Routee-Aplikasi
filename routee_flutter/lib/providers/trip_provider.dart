import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../core/data/terminal_data.dart';
import '../core/data/destinations_data.dart';
import '../core/models/itinerary_model.dart';
import '../core/models/terminal_model.dart';
import '../core/models/destination_model.dart';

class TripProvider extends ChangeNotifier {
  String _selectedTerminalId = 'gubeng';
  int _selectedHours = 6;
  ItineraryModel? _currentItinerary;
  bool _isGenerating = false;

  // Custom Trip mode state
  bool _isCustomMode = false;
  final List<DestinationModel> _customSelectedDestinations = [];

  // Navigation state
  bool _isNavigating = false;
  int _activeSpotIndex = 0;
  final Set<int> _visitedSpots = {};

  // Getters
  String get selectedTerminalId => _selectedTerminalId;
  int get selectedHours => _selectedHours;
  ItineraryModel? get currentItinerary => _currentItinerary;
  bool get isGenerating => _isGenerating;
  bool get isCustomMode => _isCustomMode;
  List<DestinationModel> get customSelectedDestinations => _customSelectedDestinations;
  bool get isNavigating => _isNavigating;
  int get activeSpotIndex => _activeSpotIndex;
  Set<int> get visitedSpots => Set.unmodifiable(_visitedSpots);

  ItinerarySpot? get activeSpot {
    if (_currentItinerary == null) return null;
    if (_activeSpotIndex >= _currentItinerary!.spots.length) return null;
    return _currentItinerary!.spots[_activeSpotIndex];
  }

  bool get isAllVisited {
    if (_currentItinerary == null) return false;
    return _visitedSpots.length >= _currentItinerary!.spots.length;
  }

  TerminalModel get selectedTerminal =>
      TerminalData.terminals.firstWhere((t) => t.id == _selectedTerminalId);

  void selectTerminal(String id) {
    _selectedTerminalId = id;
    _currentItinerary = null;
    _resetNavState();
    notifyListeners();
  }

  void selectHours(int hours) {
    _selectedHours = hours;
    _currentItinerary = null;
    _resetNavState();
    notifyListeners();
  }

  void setCustomMode(bool value) {
    _isCustomMode = value;
    _currentItinerary = null;
    _resetNavState();
    notifyListeners();
  }

  void setItinerary(ItineraryModel itinerary) {
    _currentItinerary = itinerary;
    notifyListeners();
  }

  void toggleDestinationSelection(DestinationModel dest) {
    final exists = _customSelectedDestinations.any((d) => d.id == dest.id);
    if (exists) {
      _customSelectedDestinations.removeWhere((d) => d.id == dest.id);
    } else {
      _customSelectedDestinations.add(dest);
    }
    _currentItinerary = null;
    _resetNavState();
    notifyListeners();
  }

  void reorderCustomDestinations(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _customSelectedDestinations.removeAt(oldIndex);
    _customSelectedDestinations.insert(newIndex, item);
    _currentItinerary = null;
    _resetNavState();
    notifyListeners();
  }

  void clearCustomDestinations() {
    _customSelectedDestinations.clear();
    _currentItinerary = null;
    _resetNavState();
    notifyListeners();
  }

  void startNavigation() {
    _isNavigating = true;
    _activeSpotIndex = 0;
    _visitedSpots.clear();
    notifyListeners();
  }

  void stopNavigation() {
    _isNavigating = false;
    _resetNavState();
    notifyListeners();
  }

  void markSpotVisited(int index) {
    _visitedSpots.add(index);
    if (_currentItinerary != null) {
      for (int i = 0; i < _currentItinerary!.spots.length; i++) {
        if (!_visitedSpots.contains(i)) {
          _activeSpotIndex = i;
          notifyListeners();
          return;
        }
      }
      _activeSpotIndex = _currentItinerary!.spots.length;
    }
    notifyListeners();
  }

  void setActiveSpot(int index) {
    _activeSpotIndex = index;
    notifyListeners();
  }

  void _resetNavState() {
    _isNavigating = false;
    _activeSpotIndex = 0;
    _visitedSpots.clear();
  }

  Future<void> generateItinerary() async {
    _isGenerating = true;
    _resetNavState();
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1800));

    final terminal = selectedTerminal;
    
    if (_isCustomMode) {
      if (_customSelectedDestinations.isEmpty) {
        _isGenerating = false;
        notifyListeners();
        return;
      }

      // Generate dynamic times starting at 09:00
      final List<String> times = [];
      DateTime currentTime = DateTime(2026, 6, 2, 9, 0);
      for (int i = 0; i < _customSelectedDestinations.length; i++) {
        final hourStr = currentTime.hour.toString().padLeft(2, '0');
        final minStr = currentTime.minute.toString().padLeft(2, '0');
        times.add('$hourStr:$minStr');
        currentTime = currentTime.add(const Duration(minutes: 90)); // 1.5 hours per stop
      }

      final List<ItinerarySpot> sequencedSpots = [];
      double lastLat = terminal.lat;
      double lastLng = terminal.lng;

      for (int i = 0; i < _customSelectedDestinations.length; i++) {
        final s = _customSelectedDestinations[i];
        final double distMeters = Geolocator.distanceBetween(
          lastLat, lastLng,
          s.lat, s.lng,
        );
        final double distKm = distMeters / 1000.0;
        final String distanceLabel = i == 0
            ? '${distKm.toStringAsFixed(1)} km dari ${terminal.name}'
            : '${distKm.toStringAsFixed(1)} km dari spot sebelumnya';

        sequencedSpots.add(ItinerarySpot(
          id: s.id,
          name: s.name,
          image: s.image,
          timeLabel: times[i],
          duration: s.duration,
          ticketPrice: _parseTicketPrice(s.ticket),
          distance: distanceLabel,
          category: s.category,
        ));

        lastLat = s.lat;
        lastLng = s.lng;
      }

      _currentItinerary = ItineraryModel(
        terminalName: terminal.name,
        hours: _customSelectedDestinations.length * 2,
        spots: sequencedSpots,
        food: terminal.foodRec,
        transport: terminal.transport,
      );
    } else {
      final int spotCount = _selectedHours == 4 ? 2 : _selectedHours == 6 ? 3 : 4;

      // Map each spot to its DestinationModel to find coordinates
      final List<MapEntry<ItinerarySpot, DestinationModel>> spotsWithCoords = terminal.spots.map((spot) {
        final dest = DestinationsData.destinations.firstWhere(
          (d) => d.id == spot.id,
          orElse: () => DestinationModel(
            id: spot.id, name: spot.name, category: spot.category, image: spot.image,
            shortDesc: '', description: '', location: '', hours: '', ticket: '', duration: '',
            rating: 4.5, lat: terminal.lat, lng: terminal.lng, // fallback to terminal
          ),
        );
        return MapEntry(spot, dest);
      }).toList();

      if (spotsWithCoords.isNotEmpty) {
        // Pick a random starting spot as seed
        final seedIndex = (DateTime.now().millisecondsSinceEpoch % spotsWithCoords.length).floor();
        final seed = spotsWithCoords[seedIndex];

        // Sort all spots by distance to the seed spot
        spotsWithCoords.sort((a, b) {
          final distA = Geolocator.distanceBetween(seed.value.lat, seed.value.lng, a.value.lat, a.value.lng);
          final distB = Geolocator.distanceBetween(seed.value.lat, seed.value.lng, b.value.lat, b.value.lng);
          return distA.compareTo(distB);
        });

        // Take the closest spotCount spots (including the seed)
        final selectedEntries = spotsWithCoords.take(spotCount).toList();

        // Sort the selected spots in logical sequence based on distance to starting terminal
        selectedEntries.sort((a, b) {
          final distA = Geolocator.distanceBetween(terminal.lat, terminal.lng, a.value.lat, a.value.lng);
          final distB = Geolocator.distanceBetween(terminal.lat, terminal.lng, b.value.lat, b.value.lng);
          return distA.compareTo(distB);
        });

        final List<String> times = _selectedHours == 4
            ? ['09:00', '11:00']
            : _selectedHours == 6
                ? ['09:00', '10:30', '13:30']
                : ['09:00', '10:30', '13:00', '15:00'];

        final List<ItinerarySpot> sequencedSpots = [];
        double lastLat = terminal.lat;
        double lastLng = terminal.lng;

        for (int i = 0; i < selectedEntries.length; i++) {
          final entry = selectedEntries[i];
          final s = entry.key;
          final dest = entry.value;

          final double distMeters = Geolocator.distanceBetween(lastLat, lastLng, dest.lat, dest.lng);
          final double distKm = distMeters / 1000.0;
          final String distanceLabel = i == 0
              ? '${distKm.toStringAsFixed(1)} km dari ${terminal.name}'
              : '${distKm.toStringAsFixed(1)} km dari spot sebelumnya';

          sequencedSpots.add(ItinerarySpot(
            id: s.id,
            name: s.name,
            image: s.image,
            timeLabel: times[i],
            duration: s.duration,
            ticketPrice: s.ticketPrice,
            distance: distanceLabel,
            category: s.category,
          ));

          lastLat = dest.lat;
          lastLng = dest.lng;
        }

        _currentItinerary = ItineraryModel(
          terminalName: terminal.name,
          hours: _selectedHours,
          spots: sequencedSpots,
          food: terminal.foodRec,
          transport: terminal.transport,
        );
      }
    }

    _isGenerating = false;
    notifyListeners();
  }

  int _parseTicketPrice(String ticketStr) {
    if (ticketStr.toLowerCase().contains('gratis')) return 0;
    final cleanStr = ticketStr.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanStr) ?? 0;
  }

  void resetItinerary() {
    _currentItinerary = null;
    _resetNavState();
    notifyListeners();
  }
}
