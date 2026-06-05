import 'package:flutter/material.dart';

class ExploreProvider extends ChangeNotifier {
  String _activeTab = 'Heritage';
  String _searchQuery = '';
  String _umkmFilter = 'all';

  String get activeTab => _activeTab;
  String get searchQuery => _searchQuery;
  String get umkmFilter => _umkmFilter;

  void setTab(String tab) {
    _activeTab = tab;
    _searchQuery = '';
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query.toLowerCase().trim();
    notifyListeners();
  }

  void setUmkmFilter(String filter) {
    _umkmFilter = filter;
    notifyListeners();
  }
}
