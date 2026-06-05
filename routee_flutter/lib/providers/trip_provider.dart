import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../core/data/terminal_data.dart';
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
      int spotCount = _selectedHours == 4 ? 2 : _selectedHours == 6 ? 3 : 4;

      final rawSpots = List<ItinerarySpot>.from(terminal.spots)..shuffle();
      final selectedSpots = rawSpots.take(spotCount).toList();

      selectedSpots.sort((a, b) =>
          terminal.spots.indexOf(a).compareTo(terminal.spots.indexOf(b)));

      final List<String> times = _selectedHours == 4
          ? ['09:00', '11:00']
          : _selectedHours == 6
              ? ['09:00', '10:30', '13:30']
              : ['09:00', '10:30', '13:00', '15:00'];

      final List<ItinerarySpot> sequencedSpots = [];
      for (int i = 0; i < selectedSpots.length; i++) {
        final s = selectedSpots[i];
        final distanceLabel = i == 0
            ? (s.distance.contains('dari') ? s.distance : '${s.distance} dari stasiun')
            : s.distance;

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
      }

      _currentItinerary = ItineraryModel(
        terminalName: terminal.name,
        hours: _selectedHours,
        spots: sequencedSpots,
        food: terminal.foodRec,
        transport: terminal.transport,
      );
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
