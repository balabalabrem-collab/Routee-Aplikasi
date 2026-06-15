import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/driver_model.dart';
import '../core/models/payment_model.dart';
import '../core/models/chat_model.dart';
import '../core/data/driver_data.dart';
import '../core/services/midtrans_service.dart';

class RentalProvider extends ChangeNotifier {
  DriverModel? _selectedDriver;
  String _selectedVehicleType = 'Motor';
  int _durationHours = 8;
  String _rentalStatus = 'idle'; // idle, searching, driverFound, onTrip, completed
  PaymentModel? _currentPayment;
  String _paymentMethod = '';
  int? _customPrice;
  bool _isOjek = false;
  String _pickupTime = '09:00';
  List<String> _ojekRoute = [];
  final List<ChatMessage> _chatMessages = [];

  // Renter Reservation Details
  String _renterName = '';
  String _renterPhone = '';
  String _rentalDate = '';

  // Payment History
  final List<PaymentModel> _paymentHistory = [];

  RentalProvider() {
    _loadFromPrefs();
  }

  DriverModel? get selectedDriver => _selectedDriver;
  String get selectedVehicleType => _selectedVehicleType;
  int get durationHours => _durationHours;
  String get rentalStatus => _rentalStatus;
  PaymentModel? get currentPayment => _currentPayment;
  String get paymentMethod => _paymentMethod;
  int? get customPrice => _customPrice;
  bool get isOjek => _isOjek;
  String get pickupTime => _pickupTime;
  List<String> get ojekRoute => _ojekRoute;
  List<ChatMessage> get chatMessages => _chatMessages;
  List<PaymentModel> get paymentHistory => List.unmodifiable(_paymentHistory);

  String get renterName => _renterName;
  String get renterPhone => _renterPhone;
  String get rentalDate => _rentalDate;

  /// True if selected payment method is COD (tidak lewat Midtrans)
  bool get isCodPayment => _paymentMethod == 'cod';

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedVehicleType = prefs.getString('rental_vehicle_type') ?? 'Motor';
      _durationHours = prefs.getInt('rental_duration_hours') ?? 8;
      _rentalStatus = prefs.getString('rental_status') ?? 'idle';
      _paymentMethod = prefs.getString('rental_payment_method') ?? '';
      _customPrice = prefs.containsKey('rental_custom_price') ? prefs.getInt('rental_custom_price') : null;
      _isOjek = prefs.getBool('rental_is_ojek') ?? false;
      _pickupTime = prefs.getString('rental_pickup_time') ?? '09:00';
      _ojekRoute = prefs.getStringList('rental_ojek_route') ?? [];

      _renterName = prefs.getString('rental_renter_name') ?? '';
      _renterPhone = prefs.getString('rental_renter_phone') ?? '';
      _rentalDate = prefs.getString('rental_rental_date') ?? '';

      final driverId = prefs.getString('rental_driver_id');
      if (driverId != null) {
        _selectedDriver = DriverData.findById(driverId);
      }

      final paymentJson = prefs.getString('rental_current_payment');
      if (paymentJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(paymentJson);
        _currentPayment = _paymentFromMap(decoded);
      }

      final chatJson = prefs.getString('rental_chat_messages');
      _chatMessages.clear();
      if (chatJson != null) {
        final List<dynamic> decodedList = jsonDecode(chatJson);
        for (var m in decodedList) {
          _chatMessages.add(ChatMessage(
            id: m['id'] ?? '',
            senderId: m['senderId'] ?? '',
            message: m['message'] ?? '',
            timestamp: DateTime.tryParse(m['timestamp'] ?? '') ?? DateTime.now(),
            isFromDriver: m['isFromDriver'] ?? false,
          ));
        }
      }

      // Load payment history
      final historyJson = prefs.getString('rental_payment_history');
      _paymentHistory.clear();
      if (historyJson != null) {
        final List<dynamic> histList = jsonDecode(historyJson);
        for (var h in histList) {
          _paymentHistory.add(_paymentFromMap(h));
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading rental prefs: $e');
    }
  }

  PaymentModel _paymentFromMap(Map<String, dynamic> decoded) {
    return PaymentModel(
      id: decoded['id'] ?? '',
      driverId: decoded['driverId'] ?? '',
      vehicleType: decoded['vehicleType'] ?? '',
      method: decoded['method'] ?? '',
      rentalPrice: decoded['rentalPrice'] ?? 0,
      serviceFee: decoded['serviceFee'] ?? 0,
      totalAmount: decoded['totalAmount'] ?? 0,
      status: decoded['status'] ?? '',
      createdAt: DateTime.tryParse(decoded['createdAt'] ?? '') ?? DateTime.now(),
      referenceNumber: decoded['referenceNumber'] ?? '',
      durationHours: decoded['durationHours'] ?? 8,
    );
  }

  Map<String, dynamic> _paymentToMap(PaymentModel p) => {
    'id': p.id,
    'driverId': p.driverId,
    'vehicleType': p.vehicleType,
    'method': p.method,
    'rentalPrice': p.rentalPrice,
    'serviceFee': p.serviceFee,
    'totalAmount': p.totalAmount,
    'status': p.status,
    'createdAt': p.createdAt.toIso8601String(),
    'referenceNumber': p.referenceNumber,
    'durationHours': p.durationHours,
  };

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('rental_vehicle_type', _selectedVehicleType);
      await prefs.setInt('rental_duration_hours', _durationHours);
      await prefs.setString('rental_status', _rentalStatus);
      await prefs.setString('rental_payment_method', _paymentMethod);
      if (_customPrice == null) {
        await prefs.remove('rental_custom_price');
      } else {
        await prefs.setInt('rental_custom_price', _customPrice!);
      }
      await prefs.setBool('rental_is_ojek', _isOjek);
      await prefs.setString('rental_pickup_time', _pickupTime);
      await prefs.setStringList('rental_ojek_route', _ojekRoute);

      await prefs.setString('rental_renter_name', _renterName);
      await prefs.setString('rental_renter_phone', _renterPhone);
      await prefs.setString('rental_rental_date', _rentalDate);

      if (_selectedDriver == null) {
        await prefs.remove('rental_driver_id');
      } else {
        await prefs.setString('rental_driver_id', _selectedDriver!.id);
      }

      if (_currentPayment == null) {
        await prefs.remove('rental_current_payment');
      } else {
        await prefs.setString('rental_current_payment', jsonEncode(_paymentToMap(_currentPayment!)));
      }

      final chatList = _chatMessages.map((m) => {
        'id': m.id,
        'senderId': m.senderId,
        'message': m.message,
        'timestamp': m.timestamp.toIso8601String(),
        'isFromDriver': m.isFromDriver,
      }).toList();
      await prefs.setString('rental_chat_messages', jsonEncode(chatList));

      // Save payment history
      final histList = _paymentHistory.map(_paymentToMap).toList();
      await prefs.setString('rental_payment_history', jsonEncode(histList));

    } catch (e) {
      debugPrint('Error saving rental prefs: $e');
    }
  }

  void setRenterInfo({required String name, required String phone, required String date}) {
    _renterName = name;
    _renterPhone = phone;
    _rentalDate = date;
    _saveToPrefs();
    notifyListeners();
  }

  void setIsOjek(bool val) {
    _isOjek = val;
    _saveToPrefs();
    notifyListeners();
  }

  void setPickupTime(String time) {
    _pickupTime = time;
    _saveToPrefs();
    notifyListeners();
  }

  void setOjekRoute(List<String> route) {
    _ojekRoute = route;
    _saveToPrefs();
    notifyListeners();
  }

  int get pricePerHour {
    return _selectedVehicleType == 'Motor' ? 10000 : 40000;
  }

  int get rentalPrice => _customPrice ?? (pricePerHour * _durationHours);
  int get serviceFee => (rentalPrice * 0.1).round();
  int get totalAmount => rentalPrice + serviceFee;

  void setCustomPrice(int? price) {
    _customPrice = price;
    _saveToPrefs();
    notifyListeners();
  }

  void selectDriver(DriverModel driver) {
    _selectedDriver = driver;
    _selectedVehicleType = driver.vehicleType;
    _saveToPrefs();
    notifyListeners();
  }

  void setVehicleType(String type) {
    _selectedVehicleType = type;
    _saveToPrefs();
    notifyListeners();
  }

  void setDuration(int hours) {
    _durationHours = hours;
    _saveToPrefs();
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    _saveToPrefs();
    notifyListeners();
  }

  void addChatMessage(ChatMessage message) {
    _chatMessages.add(message);
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> searchDriver() async {
    _rentalStatus = 'searching';
    _saveToPrefs();
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _rentalStatus = 'driverFound';
    _saveToPrefs();
    notifyListeners();
  }

  /// Inisiasi pembayaran via Midtrans Snap (non-COD).
  /// Mengembalikan map dengan success, snap_token, redirect_url, order_id, atau pesan error.
  Future<Map<String, dynamic>> initiatePayment() async {
    final result = await MidtransService.createTransaction(
      amount: totalAmount,
      renterName: _renterName.isNotEmpty ? _renterName : 'Tamu',
      renterPhone: _renterPhone.isNotEmpty ? _renterPhone : '081234567890',
      vehicleType: _selectedVehicleType,
      driverName: _selectedDriver?.name,
      paymentMethod: _paymentMethod,
    );

    if (result['success'] == true) {
      _currentPayment = PaymentModel(
        id: 'pay-${DateTime.now().millisecondsSinceEpoch}',
        driverId: _selectedDriver?.id ?? '',
        vehicleType: _selectedVehicleType,
        method: _paymentMethod,
        rentalPrice: rentalPrice,
        serviceFee: serviceFee,
        totalAmount: totalAmount,
        status: 'pending',
        createdAt: DateTime.now(),
        referenceNumber: result['order_id'] ?? '',
        durationHours: _durationHours,
      );
      _saveToPrefs();
      notifyListeners();
    }
    return result;
  }

  /// Proses COD: langsung tandai sebagai pending (konfirmasi manual via admin).
  /// Mengembalikan PaymentModel dengan status 'cod_pending'.
  PaymentModel processCodPayment() {
    final ref = 'COD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    _currentPayment = PaymentModel(
      id: 'pay-${DateTime.now().millisecondsSinceEpoch}',
      driverId: _selectedDriver?.id ?? '',
      vehicleType: _selectedVehicleType,
      method: 'cod',
      rentalPrice: rentalPrice,
      serviceFee: serviceFee,
      totalAmount: totalAmount,
      status: 'cod_pending',
      createdAt: DateTime.now(),
      referenceNumber: ref,
      durationHours: _durationHours,
    );
    _rentalStatus = 'driverFound'; // driver ditemukan, bayar di tempat
    _saveToPrefs();
    notifyListeners();
    return _currentPayment!;
  }

  /// Cek status pembayaran dari server Midtrans.
  /// Mengembalikan true jika settlement/capture/success.
  Future<bool> checkPaymentStatus() async {
    if (_currentPayment == null) return false;

    // COD: selalu anggap berhasil setelah dikonfirmasi user
    if (_currentPayment!.method == 'cod') {
      _currentPayment = PaymentModel(
        id: _currentPayment!.id,
        driverId: _currentPayment!.driverId,
        vehicleType: _currentPayment!.vehicleType,
        method: _currentPayment!.method,
        rentalPrice: _currentPayment!.rentalPrice,
        serviceFee: _currentPayment!.serviceFee,
        totalAmount: _currentPayment!.totalAmount,
        status: 'success',
        createdAt: _currentPayment!.createdAt,
        referenceNumber: _currentPayment!.referenceNumber,
        durationHours: _currentPayment!.durationHours,
      );
      _rentalStatus = 'onTrip';
      _addToHistory(_currentPayment!);
      _saveToPrefs();
      notifyListeners();
      return true;
    }

    // Midtrans real check
    final status = await MidtransService.checkPaymentStatus(_currentPayment!.referenceNumber);

    if (status == 'settlement' || status == 'capture' || status == 'success') {
      _currentPayment = PaymentModel(
        id: _currentPayment!.id,
        driverId: _currentPayment!.driverId,
        vehicleType: _currentPayment!.vehicleType,
        method: _currentPayment!.method,
        rentalPrice: _currentPayment!.rentalPrice,
        serviceFee: _currentPayment!.serviceFee,
        totalAmount: _currentPayment!.totalAmount,
        status: 'success',
        createdAt: _currentPayment!.createdAt,
        referenceNumber: _currentPayment!.referenceNumber,
        durationHours: _currentPayment!.durationHours,
      );
      _rentalStatus = 'onTrip';
      _addToHistory(_currentPayment!);
      _saveToPrefs();
      notifyListeners();
      return true;
    }
    return false;
  }

  void _addToHistory(PaymentModel payment) {
    // Hindari duplikat
    final exists = _paymentHistory.any((p) => p.referenceNumber == payment.referenceNumber);
    if (!exists) {
      _paymentHistory.insert(0, payment); // newest first
    }
  }

  void completeTrip() {
    _rentalStatus = 'completed';
    _saveToPrefs();
    notifyListeners();
  }

  void reset() {
    _selectedDriver = null;
    _selectedVehicleType = 'Motor';
    _durationHours = 8;
    _rentalStatus = 'idle';
    _currentPayment = null;
    _paymentMethod = '';
    _customPrice = null;
    _isOjek = false;
    _pickupTime = '09:00';
    _ojekRoute = [];
    _chatMessages.clear();
    _renterName = '';
    _renterPhone = '';
    _rentalDate = '';
    _saveToPrefs();
    notifyListeners();
  }
}
