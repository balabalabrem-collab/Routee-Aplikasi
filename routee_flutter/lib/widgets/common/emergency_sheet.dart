import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/bounceable.dart';

class EmergencyContactSheet extends StatelessWidget {
  const EmergencyContactSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const EmergencyContactSheet(),
    );
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      debugPrint('Could not launch phone dialer: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Bantuan Darurat',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Kontak darurat dan bantuan informasi turis di Kota Surabaya',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // 112 Hotline
          _buildEmergencyCard(
            icon: '🚨',
            title: 'Call Center Darurat',
            phone: '112',
            subtitle: 'Bebas pulsa untuk pemadam, ambulans, & kejadian darurat umum.',
            color: AppColors.error,
          ),
          const SizedBox(height: 12),

          // Ambulans & RSUD
          _buildEmergencyCard(
            icon: '🚑',
            title: 'RSUD Dr. Soetomo',
            phone: '0315501078',
            subtitle: 'Instalasi Gawat Darurat & Pelayanan Medis Rumah Sakit Pusat.',
            color: Colors.teal,
          ),
          const SizedBox(height: 12),

          // Polisi
          _buildEmergencyCard(
            icon: '🚓',
            title: 'Polrestabes Surabaya',
            phone: '0313523927',
            subtitle: 'Keamanan, ketertiban, & pengaduan tindakan kriminalitas.',
            color: Colors.blue.shade800,
          ),
          const SizedBox(height: 12),

          // Tourist Info
          _buildEmergencyCard(
            icon: '📍',
            title: 'Surabaya Tourist Info',
            phone: '0315340444',
            subtitle: 'Pusat Informasi Pariwisata & Layanan Wisatawan Balai Pemuda.',
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard({
    required String icon,
    required String title,
    required String phone,
    required String subtitle,
    required Color color,
  }) {
    return Bounceable(
      onTap: () => _makeCall(phone),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: color),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.phone_forwarded_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}
