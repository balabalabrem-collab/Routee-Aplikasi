import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'Bahasa Indonesia'; // 'Bahasa Indonesia' or 'English'

  String get currentLanguage => _currentLanguage;
  String get localeCode => _currentLanguage == 'English' ? 'en' : 'id';

  void setLanguage(String language) {
    if (language == 'Bahasa Indonesia' || language == 'English') {
      _currentLanguage = language;
      notifyListeners();
    }
  }

  // Translation lookup helper
  String translate(String key) {
    final Map<String, Map<String, String>> translations = {
      'id': {
        // App bar & Bottom Nav
        'home': 'Beranda',
        'explore': 'Jelajah',
        'trip': 'Trip',
        'map': 'Peta',
        'umkm': 'UMKM',
        'rental': 'Sewa',
        'profile': 'Profil Saya',
        
        // Profile Screen
        'account_security': 'Akun & Keamanan',
        'change_profile': 'Ubah Data Diri',
        'change_profile_sub': 'Kelola nama, nomor telepon, dan email',
        'change_pass': 'Ubah Password',
        'change_pass_sub': 'Ganti kata sandi akun secara berkala',
        'tx_history': 'Riwayat Transaksi',
        'tx_history_sub': 'Lihat semua penyewaan dan pembayaran kamu',
        'app_help': 'Aplikasi & Bantuan',
        'notifications': 'Notifikasi',
        'notifications_sub': 'Atur pemberitahuan perjalanan & promo',
        'language': 'Bahasa',
        'about': 'Tentang Routee',
        'about_sub': 'Versi 1.1.0 • Surabaya Heritage App',
        'logout': 'Keluar dari Akun',
        'logout_title': 'Keluar Akun?',
        'logout_confirm': 'Apakah kamu yakin ingin keluar dari akun Routee?',
        'cancel': 'Batal',
        'logout_btn': 'Keluar',
        'save_changes': 'Simpan Perubahan',
        
        // Stats
        'total_trips': 'Total Perjalanan',
        'saved_destinations': 'Destinasi Disimpan',
        'member_silver': 'Member Silver',
        'guest_mode': 'Masuk sebagai Tamu',
        'login_cta': 'Login / Daftar Sekarang',

        // Trip Screen
        'trip_planner': 'Trip Planner',
        'trip_subtitle': 'Buat itinerary 1-hari terbaikmu',
        'start_navigation': 'Mulai Navigasi',
        'stop_navigation': 'Hentikan Navigasi',
        'restart_itinerary': 'Ulangi Rencana Perjalanan',
        'generate_itinerary': 'Buat Jadwal Otomatis',
        'custom_itinerary': 'Atur Jadwal Sendiri',
        'select_duration': 'Pilih Durasi Perjalanan',
        'select_start': 'Pilih Titik Keberangkatan',
        'dest_count': 'Destinasi Terpilih',
        'clear_all': 'Hapus Semua',
        'done': 'Selesai',
        'start_journey_map': 'Mulai Perjalanan di Peta',
        
        // Detail Screen
        'visitor_rating': 'Rating Pengunjung',
        'opening_hours': 'Jam Buka',
        'ticket': 'Tiket',
        'duration': 'Durasi',
        'location': 'Lokasi',
        'about_dest': 'Tentang Destinasi',
        'add_to_trip': 'Tambahkan ke Trip Planner',
        'view_on_map': 'Lihat di Peta',
        'share_copied': 'Tautan berhasil disalin!',
        
        // Payment Screen
        'order_summary': 'Ringkasan Pesanan',
        'payment_method': 'Metode Pembayaran',
        'confirmation': 'Konfirmasi',
        'pay_now': 'Bayar Sekarang',
        'continue': 'Lanjutkan',
        'total_payment': 'Total Bayar',
        'payment_processing': 'Memproses pembayaran...',
        'payment_success': 'Pembayaran Berhasil! 🎉',
        'driver_otw': 'Driver sedang menuju lokasi penjemputan',
        'ref_number': 'Nomor Referensi',
        'chat_driver': 'Chat Driver',
        'track_driver': 'Lacak Driver',
        'back_home': 'Kembali ke Beranda',
      },
      'en': {
        // App bar & Bottom Nav
        'home': 'Home',
        'explore': 'Explore',
        'trip': 'Trip',
        'map': 'Map',
        'umkm': 'UMKM',
        'rental': 'Rental',
        'profile': 'My Profile',
        
        // Profile Screen
        'account_security': 'Account & Security',
        'change_profile': 'Edit Profile',
        'change_profile_sub': 'Manage name, phone number, and email',
        'change_pass': 'Change Password',
        'change_pass_sub': 'Change your account password regularly',
        'tx_history': 'Transaction History',
        'tx_history_sub': 'View all your rentals and payments',
        'app_help': 'App & Support',
        'notifications': 'Notifications',
        'notifications_sub': 'Manage trip and promo alerts',
        'language': 'Language',
        'about': 'About Routee',
        'about_sub': 'Version 1.1.0 • Surabaya Heritage App',
        'logout': 'Log Out',
        'logout_title': 'Log Out?',
        'logout_confirm': 'Are you sure you want to log out from Routee?',
        'cancel': 'Cancel',
        'logout_btn': 'Log Out',
        'save_changes': 'Save Changes',
        
        // Stats
        'total_trips': 'Total Trips',
        'saved_destinations': 'Saved Destinations',
        'member_silver': 'Silver Member',
        'guest_mode': 'Guest Mode',
        'login_cta': 'Login / Register Now',

        // Trip Screen
        'trip_planner': 'Trip Planner',
        'trip_subtitle': 'Create your best 1-day itinerary',
        'start_navigation': 'Start Navigation',
        'stop_navigation': 'Stop Navigation',
        'restart_itinerary': 'Restart Itinerary',
        'generate_itinerary': 'Generate Automatically',
        'custom_itinerary': 'Custom Itinerary',
        'select_duration': 'Select Trip Duration',
        'select_start': 'Select Start Terminal',
        'dest_count': 'Selected Destinations',
        'clear_all': 'Clear All',
        'done': 'Done',
        'start_journey_map': 'Start Journey on Map',
        
        // Detail Screen
        'visitor_rating': 'Visitor Rating',
        'opening_hours': 'Opening Hours',
        'ticket': 'Ticket',
        'duration': 'Duration',
        'location': 'Location',
        'about_dest': 'About Destination',
        'add_to_trip': 'Add to Trip Planner',
        'view_on_map': 'View on Map',
        'share_copied': 'Link copied successfully!',
        
        // Payment Screen
        'order_summary': 'Order Summary',
        'payment_method': 'Payment Method',
        'confirmation': 'Confirmation',
        'pay_now': 'Pay Now',
        'continue': 'Continue',
        'total_payment': 'Total Payment',
        'payment_processing': 'Processing payment...',
        'payment_success': 'Payment Successful! 🎉',
        'driver_otw': 'Driver is heading to your pick-up location',
        'ref_number': 'Reference Number',
        'chat_driver': 'Chat Driver',
        'track_driver': 'Track Driver',
        'back_home': 'Back to Home',
      }
    };

    return translations[localeCode]?[key] ?? key;
  }

  String translateText({required String id, required String en}) {
    return _currentLanguage == 'English' ? en : id;
  }
}
