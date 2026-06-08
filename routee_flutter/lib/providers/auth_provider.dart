import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  AuthProvider() {
    _loadUsersFromPrefs();
  }

  // Mock registered users storage (initially with default accounts)
  final List<Map<String, String>> _registeredUsers = [
    {
      'email': 'admin@routee.id',
      'password': 'adminRoutee2026',
      'name': 'Administrator Routee',
      'phone': '081122334455',
      'role': 'admin',
    },
    {
      'email': 'karyawan@routee.id',
      'password': 'staffRoutee2026',
      'name': 'Budi Setiawan (Staff Operational)',
      'phone': '085566778899',
      'role': 'karyawan',
    }
  ];

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;

  Future<void> _loadUsersFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('registered_users');
      if (usersJson != null) {
        final List<dynamic> decoded = jsonDecode(usersJson);
        _registeredUsers.clear();
        for (var u in decoded) {
          _registeredUsers.add(Map<String, String>.from(u));
        }
      }
      // Ensure default accounts exist if missing
      if (!_registeredUsers.any((u) => u['email'] == 'admin@routee.id')) {
        _registeredUsers.add({
          'email': 'admin@routee.id',
          'password': 'adminRoutee2026',
          'name': 'Administrator Routee',
          'phone': '081122334455',
          'role': 'admin',
        });
      }
      if (!_registeredUsers.any((u) => u['email'] == 'karyawan@routee.id')) {
        _registeredUsers.add({
          'email': 'karyawan@routee.id',
          'password': 'staffRoutee2026',
          'name': 'Budi Setiawan (Staff Operational)',
          'phone': '085566778899',
          'role': 'karyawan',
        });
      }

      // Load active session
      final sessionJson = prefs.getString('active_user_session');
      if (sessionJson != null) {
        final decoded = jsonDecode(sessionJson);
        _currentUser = UserModel(
          id: decoded['id'] ?? '',
          name: decoded['name'] ?? '',
          email: decoded['email'] ?? '',
          phone: decoded['phone'] ?? '',
          role: decoded['role'] ?? 'user',
          avatarUrl: decoded['avatarUrl'] ?? '',
          createdAt: DateTime.tryParse(decoded['createdAt'] ?? '') ?? DateTime.now(),
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading users from prefs: $e');
    }
  }

  Future<void> _saveUsersToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = jsonEncode(_registeredUsers);
      await prefs.setString('registered_users', usersJson);
    } catch (e) {
      debugPrint('Error saving users to prefs: $e');
    }
  }

  Future<void> _saveSessionToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUser == null) {
        await prefs.remove('active_user_session');
      } else {
        final sessionMap = {
          'id': _currentUser!.id,
          'name': _currentUser!.name,
          'email': _currentUser!.email,
          'phone': _currentUser!.phone,
          'role': _currentUser!.role,
          'avatarUrl': _currentUser!.avatarUrl,
          'createdAt': _currentUser!.createdAt.toIso8601String(),
        };
        await prefs.setString('active_user_session', jsonEncode(sessionMap));
      }
    } catch (e) {
      debugPrint('Error saving session to prefs: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final user = _registeredUsers.firstWhere(
        (u) => u['email']?.toLowerCase() == email.toLowerCase() && u['password'] == password,
      );

      _currentUser = UserModel(
        id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
        name: user['name']!,
        email: user['email']!,
        phone: user['phone']!,
        role: user['role'] ?? 'user',
        createdAt: DateTime.now(),
      );

      await _saveSessionToPrefs();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    // Check if email already exists
    final exists = _registeredUsers.any((u) => u['email']?.toLowerCase() == email.toLowerCase());
    if (exists) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Register user
    _registeredUsers.add({
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'role': 'user',
    });
    await _saveUsersToPrefs();

    // Auto-login after register
    _currentUser = UserModel(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      role: 'user',
      createdAt: DateTime.now(),
    );
    await _saveSessionToPrefs();

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void updateProfile({required String name, required String email, required String phone}) {
    if (_currentUser != null) {
      // Also update in registered list so login works with new details
      final idx = _registeredUsers.indexWhere((u) => u['email'] == _currentUser!.email);
      if (idx != -1) {
        _registeredUsers[idx]['name'] = name;
        _registeredUsers[idx]['email'] = email;
        _registeredUsers[idx]['phone'] = phone;
      }
      _currentUser = UserModel(
        id: _currentUser!.id,
        name: name,
        email: email,
        phone: phone,
        createdAt: _currentUser!.createdAt,
      );
      _saveUsersToPrefs();
      _saveSessionToPrefs();
      notifyListeners();
    }
  }

  bool updatePassword(String oldPassword, String newPassword) {
    if (_currentUser == null) return false;
    final idx = _registeredUsers.indexWhere((u) => u['email'] == _currentUser!.email);
    if (idx != -1) {
      if (_registeredUsers[idx]['password'] == oldPassword) {
        _registeredUsers[idx]['password'] = newPassword;
        _saveUsersToPrefs();
        return true;
      }
    }
    return false;
  }

  List<Map<String, String>> get employees {
    return _registeredUsers.where((u) => u['role'] == 'karyawan').toList();
  }

  bool addEmployee({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) {
    final exists = _registeredUsers.any((u) => u['email']?.toLowerCase() == email.toLowerCase());
    if (exists) return false;

    _registeredUsers.add({
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'role': 'karyawan',
    });
    _saveUsersToPrefs();
    notifyListeners();
    return true;
  }

  bool updateEmployee({
    required String originalEmail,
    required String name,
    required String email,
    required String phone,
    required String password,
  }) {
    if (originalEmail.toLowerCase() != email.toLowerCase()) {
      final exists = _registeredUsers.any((u) => u['email']?.toLowerCase() == email.toLowerCase());
      if (exists) return false;
    }

    final idx = _registeredUsers.indexWhere((u) => u['email']?.toLowerCase() == originalEmail.toLowerCase());
    if (idx != -1) {
      _registeredUsers[idx]['name'] = name;
      _registeredUsers[idx]['email'] = email;
      _registeredUsers[idx]['phone'] = phone;
      _registeredUsers[idx]['password'] = password;
      _saveUsersToPrefs();
      notifyListeners();
      return true;
    }
    return false;
  }

  void deleteEmployee(String email) {
    _registeredUsers.removeWhere((u) => u['email'] == email);
    _saveUsersToPrefs();
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _saveSessionToPrefs();
    notifyListeners();
  }
}
