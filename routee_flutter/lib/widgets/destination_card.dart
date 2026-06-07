import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/models/destination_model.dart';
import 'common/bounceable.dart';

class DestinationCard extends StatelessWidget {
  final DestinationModel destination;
  final VoidCallback onTap;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Bounceable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    destination.image,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.image_rounded, size: 40, color: AppColors.textMuted),
                    ),
                  ),
                  // Gradient
                  Container(
                    decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                  ),
                  // Category badge
                  Positioned(
                    top: 10, left: 10,
                    child: _CategoryBadge(category: destination.category),
                  ),
                  // Rating
                  Positioned(
                    top: 10, right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '★ ${destination.rating}',
                        style: GoogleFonts.poppins(
                          color: AppColors.accentLight, fontSize: 11, fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  // Image source
                  Positioned(
                    bottom: 4, right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '📷 ${destination.imageSource}',
                        style: GoogleFonts.poppins(color: Colors.white60, fontSize: 7, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    destination.name,
                    style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 11, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          destination.duration,
                          style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.local_activity_rounded, size: 11, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Text(
                        destination.ticket,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: destination.ticket == 'Gratis' ? AppColors.religiFg : AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String icon;

    switch (category) {
      case 'Heritage':
        bg = AppColors.heritageBg; fg = AppColors.heritageFg; icon = '🏛';
        break;
      case 'Religi':
        bg = AppColors.religiBg; fg = AppColors.religiFg; icon = '🕌';
        break;
      default:
        bg = AppColors.culinaryBg; fg = AppColors.culinaryFg; icon = '🍜';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$icon $category',
        style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
