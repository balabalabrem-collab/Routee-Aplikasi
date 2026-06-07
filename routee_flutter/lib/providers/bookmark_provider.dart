import 'package:flutter/material.dart';

class BookmarkProvider extends ChangeNotifier {
  final Set<String> _savedDestinationIds = {};
  final Set<String> _visitedDestinationIds = {};

  List<String> get savedDestinationIds => _savedDestinationIds.toList();
  List<String> get visitedDestinationIds => _visitedDestinationIds.toList();

  int get savedCount => _savedDestinationIds.length;
  int get visitedCount => _visitedDestinationIds.length;

  bool isSaved(String id) => _savedDestinationIds.contains(id);
  bool isVisited(String id) => _visitedDestinationIds.contains(id);

  void toggleSaveDestination(String id) {
    if (_savedDestinationIds.contains(id)) {
      _savedDestinationIds.remove(id);
    } else {
      _savedDestinationIds.add(id);
    }
    notifyListeners();
  }

  void markAsVisited(String id) {
    if (!_visitedDestinationIds.contains(id)) {
      _visitedDestinationIds.add(id);
      notifyListeners();
    }
  }

  void clearAll() {
    _savedDestinationIds.clear();
    _visitedDestinationIds.clear();
    notifyListeners();
  }
}
