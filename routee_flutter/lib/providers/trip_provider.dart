import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // Preferences
  List<String> _preferredCategories = ['Heritage', 'Religi', 'Kuliner', 'UMKM'];

  TripProvider() {
    _loadFromPrefs();
  }

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
  List<String> get preferredCategories => _preferredCategories;

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

  // Helper serialization methods
  Map<String, dynamic> _itinerarySpotToMap(ItinerarySpot spot) {
    return {
      'id': spot.id,
      'name': spot.name,
      'image': spot.image,
      'timeLabel': spot.timeLabel,
      'duration': spot.duration,
      'ticketPrice': spot.ticketPrice,
      'distance': spot.distance,
      'category': spot.category,
    };
  }

  ItinerarySpot _itinerarySpotFromMap(Map<String, dynamic> map) {
    return ItinerarySpot(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      timeLabel: map['timeLabel'] ?? '',
      duration: map['duration'] ?? '',
      ticketPrice: map['ticketPrice'] ?? 0,
      distance: map['distance'] ?? '',
      category: map['category'] ?? '',
    );
  }

  Map<String, dynamic> _itineraryFoodToMap(ItineraryFood food) {
    return {
      'name': food.name,
      'image': food.image,
      'price': food.price,
      'area': food.area,
    };
  }

  ItineraryFood _itineraryFoodFromMap(Map<String, dynamic> map) {
    return ItineraryFood(
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      price: map['price'] ?? 0,
      area: map['area'] ?? '',
    );
  }

  Map<String, dynamic> _itineraryToMap(ItineraryModel it) {
    return {
      'terminalName': it.terminalName,
      'hours': it.hours,
      'spots': it.spots.map((s) => _itinerarySpotToMap(s)).toList(),
      'food': _itineraryFoodToMap(it.food),
      'transport': it.transport,
    };
  }

  ItineraryModel _itineraryFromMap(Map<String, dynamic> map) {
    return ItineraryModel(
      terminalName: map['terminalName'] ?? '',
      hours: map['hours'] ?? 8,
      spots: (map['spots'] as List<dynamic>?)
              ?.map((s) => _itinerarySpotFromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
      food: _itineraryFoodFromMap(map['food'] as Map<String, dynamic>),
      transport: List<String>.from(map['transport'] ?? []),
    );
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedTerminalId = prefs.getString('trip_selected_terminal_id') ?? 'gubeng';
      _selectedHours = prefs.getInt('trip_selected_hours') ?? 6;
      _isCustomMode = prefs.getBool('trip_is_custom_mode') ?? false;
      _isNavigating = prefs.getBool('trip_is_navigating') ?? false;
      _activeSpotIndex = prefs.getInt('trip_active_spot_index') ?? 0;
      _preferredCategories = prefs.getStringList('trip_preferred_categories') ?? ['Heritage', 'Religi', 'Kuliner', 'UMKM'];
      
      final visitedList = prefs.getStringList('trip_visited_spots') ?? [];
      _visitedSpots.clear();
      for (var str in visitedList) {
        final val = int.tryParse(str);
        if (val != null) _visitedSpots.add(val);
      }

      final customDestsJson = prefs.getString('trip_custom_selected_destinations');
      _customSelectedDestinations.clear();
      if (customDestsJson != null) {
        final List<dynamic> list = jsonDecode(customDestsJson);
        for (var item in list) {
          final id = item['id'];
          final dest = DestinationsData.destinations.firstWhere(
            (d) => d.id == id,
            orElse: () => null as dynamic,
          );
          if (dest != null) {
            _customSelectedDestinations.add(dest);
          }
        }
      }

      final itineraryJson = prefs.getString('trip_current_itinerary');
      if (itineraryJson != null) {
        _currentItinerary = _itineraryFromMap(jsonDecode(itineraryJson));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading trip prefs: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('trip_selected_terminal_id', _selectedTerminalId);
      await prefs.setInt('trip_selected_hours', _selectedHours);
      await prefs.setBool('trip_is_custom_mode', _isCustomMode);
      await prefs.setBool('trip_is_navigating', _isNavigating);
      await prefs.setInt('trip_active_spot_index', _activeSpotIndex);
      await prefs.setStringList('trip_visited_spots', _visitedSpots.map((v) => v.toString()).toList());
      await prefs.setStringList('trip_preferred_categories', _preferredCategories);

      final customList = _customSelectedDestinations.map((d) => {'id': d.id}).toList();
      await prefs.setString('trip_custom_selected_destinations', jsonEncode(customList));

      if (_currentItinerary == null) {
        await prefs.remove('trip_current_itinerary');
      } else {
        await prefs.setString('trip_current_itinerary', jsonEncode(_itineraryToMap(_currentItinerary!)));
      }
    } catch (e) {
      debugPrint('Error saving trip prefs: $e');
    }
  }

  void togglePreferredCategory(String category) {
    if (_preferredCategories.contains(category)) {
      if (_preferredCategories.length > 1) {
        _preferredCategories.remove(category);
      }
    } else {
      _preferredCategories.add(category);
    }
    _currentItinerary = null;
    _resetNavState();
    _saveToPrefs();
    notifyListeners();
  }

  void selectTerminal(String id) {
    _selectedTerminalId = id;
    _currentItinerary = null;
    _resetNavState();
    _saveToPrefs();
    notifyListeners();
  }

  void selectHours(int hours) {
    _selectedHours = hours;
    _currentItinerary = null;
    _resetNavState();
    _saveToPrefs();
    notifyListeners();
  }

  void setCustomMode(bool value) {
    _isCustomMode = value;
    _currentItinerary = null;
    _resetNavState();
    _saveToPrefs();
    notifyListeners();
  }

  void setItinerary(ItineraryModel itinerary) {
    _currentItinerary = itinerary;
    _saveToPrefs();
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
    _saveToPrefs();
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
    _saveToPrefs();
    notifyListeners();
  }

  void clearCustomDestinations() {
    _customSelectedDestinations.clear();
    _currentItinerary = null;
    _resetNavState();
    _saveToPrefs();
    notifyListeners();
  }

  void startNavigation() {
    _isNavigating = true;
    _activeSpotIndex = 0;
    _visitedSpots.clear();
    _saveToPrefs();
    notifyListeners();
  }

  void stopNavigation() {
    _isNavigating = false;
    _resetNavState();
    _saveToPrefs();
    notifyListeners();
  }

  void markSpotVisited(int index) {
    _visitedSpots.add(index);
    if (_currentItinerary != null) {
      for (int i = 0; i < _currentItinerary!.spots.length; i++) {
        if (!_visitedSpots.contains(i)) {
          _activeSpotIndex = i;
          _saveToPrefs();
          notifyListeners();
          return;
        }
      }
      _activeSpotIndex = _currentItinerary!.spots.length;
    }
    _saveToPrefs();
    notifyListeners();
  }

  void toggleSpotVisited(int index) {
    if (_visitedSpots.contains(index)) {
      _visitedSpots.remove(index);
    } else {
      _visitedSpots.add(index);
    }
    if (_currentItinerary != null) {
      _activeSpotIndex = _currentItinerary!.spots.length;
      for (int i = 0; i < _currentItinerary!.spots.length; i++) {
        if (!_visitedSpots.contains(i)) {
          _activeSpotIndex = i;
          break;
        }
      }
    }
    _saveToPrefs();
    notifyListeners();
  }

  void setActiveSpot(int index) {
    _activeSpotIndex = index;
    _saveToPrefs();
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
    _saveToPrefs();
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1800));

    final terminal = selectedTerminal;
    
    if (_isCustomMode) {
      if (_customSelectedDestinations.isEmpty) {
        _isGenerating = false;
        _saveToPrefs();
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
            rating: 4.5, lat: terminal.lat, lng: terminal.lng,
          ),
        );
        return MapEntry(spot, dest);
      }).toList();

      // Filter by preferred categories
      List<MapEntry<ItinerarySpot, DestinationModel>> filteredSpots = spotsWithCoords;
      if (_preferredCategories.isNotEmpty) {
        filteredSpots = spotsWithCoords.where((entry) {
          final cat = entry.value.category.toLowerCase();
          return _preferredCategories.any((pref) => cat.contains(pref.toLowerCase()) || pref.toLowerCase().contains(cat));
        }).toList();
      }

      // If filtering leaves nothing, fallback to all spots to prevent crash
      if (filteredSpots.isEmpty) {
        filteredSpots = spotsWithCoords;
      }

      if (filteredSpots.isNotEmpty) {
        final seedIndex = (DateTime.now().millisecondsSinceEpoch % filteredSpots.length).floor();
        final seed = filteredSpots[seedIndex];

        filteredSpots.sort((a, b) {
          final distA = Geolocator.distanceBetween(seed.value.lat, seed.value.lng, a.value.lat, a.value.lng);
          final distB = Geolocator.distanceBetween(seed.value.lat, seed.value.lng, b.value.lat, b.value.lng);
          return distA.compareTo(distB);
        });

        final selectedEntries = filteredSpots.take(spotCount).toList();

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
    _saveToPrefs();
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
    _saveToPrefs();
    notifyListeners();
  }
}
