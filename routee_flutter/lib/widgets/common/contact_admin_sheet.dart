import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class ContactAdminSheet extends StatelessWidget {
  const ContactAdminSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const ContactAdminSheet(),
    );
  }

  Future<void> _openWhatsApp() async {
    final url = Uri.parse('https://wa.me/${AppStrings.adminWhatsApp.replaceAll('+', '')}?text=Halo%20Admin%20Routee,%20saya%20butuh%20bantuan.');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
    }
  }

  Future<void> _openInstagram() async {
    final url = Uri.parse('https://www.instagram.com/${AppStrings.adminInstagram}');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching Instagram: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
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
          const SizedBox(height: 20),

          Text('Hubungi Admin', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('Butuh bantuan? Hubungi kami melalui:', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),

          const SizedBox(height: 24),

          // WhatsApp
          _ContactOption(
            imagePath: 'assets/images/—Pngtree—whatsapp icon whatsapp logo whatsapp_3584845.png',
            color: AppColors.primary,
            title: 'WhatsApp',
            subtitle: AppStrings.adminWhatsApp,
            onTap: _openWhatsApp,
            iconGradient: AppColors.primaryGradient,
          ),

          const SizedBox(height: 12),

          // Instagram
          _ContactOption(
            imagePath: 'assets/images/—Pngtree—instagram icon instagram logo vector_3584852.png',
            color: AppColors.accent,
            title: 'Instagram',
            subtitle: '@d.mily___',
            onTap: _openInstagram,
            iconGradient: AppColors.accentGradient,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ContactOption extends StatelessWidget {
  final String imagePath;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Gradient? iconGradient;

  const _ContactOption({
    required this.imagePath,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: iconGradient,
                  color: iconGradient == null ? color.withOpacity(0.15) : null,
                  shape: BoxShape.circle,
                  boxShadow: iconGradient != null ? [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ] : null,
                ),
                padding: const EdgeInsets.all(10), // slightly more room for the natural color logo
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
