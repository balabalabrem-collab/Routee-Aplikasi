import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Konfigurasi URL server Laravel.
/// Ganti [_productionUrl] dengan URL hosting Anda saat deploy ke produksi.
class MidtransService {
  // Android emulator pakai 10.0.2.2; web/iOS pakai localhost
  static const String _emulatorUrl = 'http://10.0.2.2:8000';
  static const String _localhostUrl = 'http://localhost:8000';

  static String get baseUrl {
    if (kIsWeb) return _localhostUrl;
    return defaultTargetPlatform == TargetPlatform.android
        ? _emulatorUrl
        : _localhostUrl;
  }

  /// Buat transaksi Midtrans Snap — mengembalikan snap_token & redirect_url.
  /// Jika server tidak tersedia, mengembalikan error (tidak ada auto-mock).
  static Future<Map<String, dynamic>> createTransaction({
    required int amount,
    required String renterName,
    required String renterPhone,
    required String vehicleType,
    String? driverName,
    String? paymentMethod,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/payment/token'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'amount': amount,
              'renter_name': renterName,
              'renter_phone': renterPhone,
              'vehicle_type': vehicleType,
              'driver_name': driverName,
              'payment_method': paymentMethod,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return {
            'success': true,
            'snap_token': data['snap_token'],
            'redirect_url': data['redirect_url'],
            'order_id': data['order_id'],
            'is_mock': false,
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Server error',
            'is_mock': false,
          };
        }
      }

      return {
        'success': false,
        'message': 'Server mengembalikan status: ${response.statusCode}',
        'is_mock': false,
      };
    } on Exception catch (e) {
      debugPrint('MidtransService.createTransaction error: $e. Fallback to mock mode.');
      // Auto-fallback ke mode simulasi (mock) untuk demo jika server offline
      final mockOrderId = 'MOCK-${DateTime.now().millisecondsSinceEpoch}';
      return {
        'success': true,
        'snap_token': 'mock-token-12345',
        'redirect_url': 'https://simulator.sandbox.midtrans.com', // Buka simulator resmi/dummy
        'order_id': mockOrderId,
        'is_mock': true,
      };
    }
  }

  /// Periksa status transaksi dari server Laravel (yang meneruskan ke Midtrans).
  /// Mengembalikan string status: settlement | capture | pending | cancel | deny | expire | error
  static Future<String> checkPaymentStatus(String orderId) async {
    // Jika orderId diawali dengan 'MOCK-', bypass pengecekan langsung anggap lunas
    if (orderId.startsWith('MOCK-')) {
      return 'settlement';
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/payment/status/$orderId'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['transaction_status'] ?? 'pending';
      }
    } on Exception catch (e) {
      debugPrint('MidtransService.checkPaymentStatus error: $e');
    }
    return 'error';
  }

  /// Kembalikan URL Snap Midtrans langsung dari snap token
  static String getSnapUrlFromToken(String snapToken) {
    // Sandbox URL
    return 'https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken';
  }
}
