import 'package:flutter/foundation.dart';
import '../core/models/driver_model.dart';
import '../core/models/payment_model.dart';

class RentalProvider extends ChangeNotifier {
  DriverModel? _selectedDriver;
  String _selectedVehicleType = 'Motor';
  int _durationHours = 8; // default 1 day (8 hours)
  String _rentalStatus = 'idle'; // idle, searching, driverFound, onTrip, completed
  PaymentModel? _currentPayment;
  String _paymentMethod = '';
  int? _customPrice;
  bool _isOjek = false;
  String _pickupTime = '09:00';
  List<String> _ojekRoute = [];

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

  void setIsOjek(bool val) {
    _isOjek = val;
    notifyListeners();
  }

  void setPickupTime(String time) {
    _pickupTime = time;
    notifyListeners();
  }

  void setOjekRoute(List<String> route) {
    _ojekRoute = route;
    notifyListeners();
  }

  int get pricePerHour {
    return _selectedVehicleType == 'Motor' ? 10000 : 40000;
  }

  int get rentalPrice => _customPrice ?? (pricePerHour * _durationHours);
  int get serviceFee => (rentalPrice * 0.1).round(); // 10% service fee
  int get totalAmount => rentalPrice + serviceFee;

  void setCustomPrice(int? price) {
    _customPrice = price;
    notifyListeners();
  }

  void selectDriver(DriverModel driver) {
    _selectedDriver = driver;
    _selectedVehicleType = driver.vehicleType;
    notifyListeners();
  }

  void setVehicleType(String type) {
    _selectedVehicleType = type;
    notifyListeners();
  }

  void setDuration(int hours) {
    _durationHours = hours;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  Future<void> searchDriver() async {
    _rentalStatus = 'searching';
    notifyListeners();

    // Simulate searching
    await Future.delayed(const Duration(seconds: 2));

    _rentalStatus = 'driverFound';
    notifyListeners();
  }

  Future<PaymentModel> processPayment() async {
    _rentalStatus = 'onTrip';
    notifyListeners();

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 1));

    final ref = 'RTR-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    _currentPayment = PaymentModel(
      id: 'pay-${DateTime.now().millisecondsSinceEpoch}',
      driverId: _selectedDriver?.id ?? '',
      vehicleType: _selectedVehicleType,
      method: _paymentMethod,
      rentalPrice: rentalPrice,
      serviceFee: serviceFee,
      totalAmount: totalAmount,
      status: 'success',
      createdAt: DateTime.now(),
      referenceNumber: ref,
      durationHours: _durationHours,
    );

    notifyListeners();
    return _currentPayment!;
  }

  void completeTrip() {
    _rentalStatus = 'completed';
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
    notifyListeners();
  }
}
